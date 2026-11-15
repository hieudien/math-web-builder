// Chạy các file SQL trong supabase/migrations/ (theo thứ tự tên) lên project Supabase.
// Đọc .env: supabase_url (để lấy mã project) và supabase_password (mật khẩu Postgres). Không in mật khẩu ra màn hình.
// Dùng:  npm run db:init            chạy tất cả file chưa chạy
//        npm run db:init -- --check chỉ kiểm tra kết nối, không chạy gì
import { readFileSync, readdirSync, existsSync } from "node:fs";
import pg from "pg";

const env = {};
if (!existsSync(".env")) { console.error("Không thấy file .env. Sao chép .env.example thành .env rồi điền thông tin."); process.exit(1); }
for (const line of readFileSync(".env", "utf8").split(/\r?\n/)) {
  const i = line.indexOf("=");
  if (i > 0 && !line.trim().startsWith("#")) env[line.slice(0, i).trim()] = line.slice(i + 1).trim().replace(/^["']|["']$/g, "");
}
const url = env.supabase_url || env.NEXT_PUBLIC_SUPABASE_URL, password = env.supabase_password;
if (!url || !password) { console.error("Thiếu supabase_url hoặc supabase_password trong .env."); process.exit(1); }
const ref = new URL(url).hostname.split(".")[0];

// Kết nối trực tiếp (db.<ref>.supabase.co) chỉ chạy trên IPv6; nhiều máy không có nên thử thêm các máy chủ trung gian (pooler) theo vùng.
const regions = ["ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-south-1", "us-east-1", "us-east-2", "us-west-1", "eu-central-1", "eu-west-1", "eu-west-2", "sa-east-1"];
const targets = [
  { host: `db.${ref}.supabase.co`, user: "postgres" },
  ...regions.flatMap((r) => ["aws-0", "aws-1"].map((p) => ({ host: `${p}-${r}.pooler.supabase.com`, user: `postgres.${ref}` }))),
];

async function connect() {
  for (const t of targets) {
    const c = new pg.Client({ host: t.host, port: 5432, user: t.user, password, database: "postgres", ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 8000 });
    try { await c.connect(); console.log("Đã kết nối:", t.host); return c; } catch { /* thử máy chủ kế tiếp */ }
  }
  console.error("Không kết nối được cơ sở dữ liệu. Kiểm tra supabase_url và supabase_password (mật khẩu Postgres, không phải khóa API).");
  process.exit(1);
}

const c = await connect();
if (process.argv.includes("--check")) { await c.end(); process.exit(0); }

await c.query("create table if not exists public._applied_migrations (name text primary key, applied_at timestamptz not null default now())");
await c.query("alter table public._applied_migrations enable row level security"); // không cho khóa công khai đọc
const done = new Set((await c.query("select name from public._applied_migrations")).rows.map((r) => r.name));
const files = readdirSync("supabase/migrations").filter((f) => f.endsWith(".sql")).sort();
for (const f of files) {
  if (done.has(f)) { console.log("Bỏ qua (đã chạy):", f); continue; }
  console.log("Đang chạy:", f);
  try {
    await c.query("begin");
    await c.query(readFileSync(`supabase/migrations/${f}`, "utf8"));
    await c.query("insert into public._applied_migrations(name) values ($1)", [f]);
    await c.query("commit");
  } catch (e) {
    await c.query("rollback");
    console.error("Lỗi ở", f + ":", e.message);
    process.exit(1);
  }
}
console.log("Xong.");
await c.end();
