-- MathStep AI: schema cơ sở dữ liệu cuối cùng (gộp từ 39 migration của bản gốc).
-- Chạy MỘT lần trên project Supabase trống. Không chứa dữ liệu, không chứa bí mật.
-- Nguyên tắc: không xóa cứng dữ liệu (trigger chặn); xóa link/học sinh/đề chỉ đặt deleted_at.

-- ============ BẢNG ============

create table teacher_settings (
  teacher_id uuid primary key references auth.users(id) on delete cascade,
  gemini_key_enc text,                                   -- khóa Gemini đã mã hóa AES-256-GCM, không bao giờ trả về trình duyệt
  model text not null default 'gemini-3.1-flash-lite',
  temperature real not null default 0.3,
  updated_at timestamptz not null default now(),
  provider text not null default 'gemini' check (provider = 'gemini')
);

create table problems (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id) on delete cascade,
  code text not null,                                    -- mã đề, vd TC01
  content jsonb not null,                                -- toàn bộ đề (xem lib/schema/problem.ts)
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index problems_teacher_id_idx on problems (teacher_id) where deleted_at is null;
-- mã đề không trùng trong cùng giáo viên (chỉ tính đề chưa xóa)
create unique index problems_teacher_code_live on problems (teacher_id, code) where deleted_at is null;

create table problem_versions (
  id bigint generated always as identity primary key,
  problem_id uuid not null references problems(id) on delete cascade,
  teacher_id uuid not null references auth.users(id) on delete cascade,
  version int not null,
  content jsonb not null,
  created_at timestamptz not null default now()
);
create index problem_versions_idx on problem_versions (problem_id, version desc);

create table public_links (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id) on delete cascade,
  slug text not null unique,
  label text not null,
  tag text check (tag = any (array['pre','post','experiment','control'])),  -- trước / sau / thực nghiệm / đối chứng
  problems_snapshot jsonb not null,                      -- bản đề lúc tạo link
  active boolean not null default true,
  expires_at timestamptz,
  max_messages int not null default 40,
  created_at timestamptz not null default now(),
  visits int not null default 0,
  session_count int not null default 0,
  deleted_at timestamptz
);
create index public_links_teacher_id_idx on public_links (teacher_id);

create table students (
  teacher_id uuid not null references auth.users(id) on delete cascade,
  code text not null,                                    -- vd NGUYENVANA.8A1
  name text,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  deleted_at timestamptz,
  class text,
  primary key (teacher_id, code)
);

create table chat_sessions (
  id uuid primary key default gen_random_uuid(),
  link_id uuid not null references public_links(id) on delete cascade,
  anon_id uuid not null,                                 -- cookie ẩn danh của trình duyệt học sinh
  seq int not null,
  problem_code text not null,
  step int not null default 1,
  hint_level int not null default 1,
  status text not null default 'active' check (status = any (array['active','done','abandoned'])),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  student_code text,
  student_name text,
  revealed int not null default 0,
  struggled int not null default 0,
  problem_snapshot jsonb,                                -- bản đề lúc học sinh mở bài
  student_class text,
  restarted boolean not null default false
);
create index chat_sessions_anon_idx on chat_sessions (anon_id, started_at desc);
create index chat_sessions_link_id_idx on chat_sessions (link_id);
create index chat_sessions_resume_idx on chat_sessions (link_id, student_code, problem_code, started_at desc) where not restarted;
create index chat_sessions_started_idx on chat_sessions (started_at desc);
create index chat_sessions_student_idx on chat_sessions (link_id, student_code);

create table messages (
  id bigint generated always as identity primary key,
  session_id uuid not null references chat_sessions(id) on delete cascade,
  role text not null check (role = any (array['student','bot'])),
  content text not null,
  step int,
  hint_level int,
  ts timestamptz not null default now(),
  meta jsonb not null default '{}'::jsonb                -- kind, ai_ms, v...
);
create index messages_session_id_id_idx on messages (session_id, id);

create table session_evals (
  session_id uuid primary key references chat_sessions(id) on delete cascade,
  identify int not null,                                 -- hiểu đề bài (0-3)
  plan int not null,                                     -- lập kế hoạch giải (0-3)
  calculate int not null,                                -- thực hiện kế hoạch (0-3)
  explain int not null,                                  -- kiểm tra và đánh giá (0-3)
  total int not null,
  final_correct boolean not null,
  max_hint_level int not null,
  hint_count int not null,
  errors text[] not null default '{}',
  duration_s int not null,
  survey_likert int check (survey_likert >= 1 and survey_likert <= 5),
  confidence int check (confidence >= 1 and confidence <= 5),
  gaps text[] not null default '{}'
);

create table session_analysis (
  session_id uuid primary key references chat_sessions(id) on delete cascade,
  content jsonb not null,
  updated_at timestamptz not null default now()
);

create table student_advice (
  teacher_id uuid not null references auth.users(id) on delete cascade,
  student_code text not null,
  content jsonb not null,
  sessions int not null,
  updated_at timestamptz not null default now(),
  primary key (teacher_id, student_code)
);

create table student_shares (
  token text primary key,
  teacher_id uuid not null references auth.users(id) on delete cascade,
  student_code text not null,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  foreign key (teacher_id, student_code) references students(teacher_id, code)
);
create unique index student_shares_one_live on student_shares (teacher_id, student_code) where revoked_at is null;

create table import_batches (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  file_name text not null default '',
  grade int not null check (grade >= 1 and grade <= 12),
  status text not null default 'draft' check (status = any (array['draft','confirmed','cancelled'])),
  confirmed_at timestamptz,
  sources int not null default 0,
  read_errors jsonb not null default '[]'::jsonb,
  items jsonb not null default '[]'::jsonb
);
create index import_batches_teacher_idx on import_batches (teacher_id, created_at desc);

create table activity_logs (
  id bigint generated always as identity primary key,
  ts timestamptz not null default now(),
  actor_type text not null check (actor_type = any (array['teacher','student','system'])),
  teacher_id uuid references auth.users(id) on delete set null,
  anon_id uuid,
  link_id uuid references public_links(id) on delete set null,
  action text not null,
  meta jsonb not null default '{}'::jsonb
);
create index activity_logs_link_id_ts_idx on activity_logs (link_id, ts desc);
create index activity_logs_teacher_action_ts_idx on activity_logs (teacher_id, action, ts desc);
create index activity_logs_teacher_id_idx on activity_logs (teacher_id, id desc);
create index activity_logs_teacher_id_ts_idx on activity_logs (teacher_id, ts desc);
create index activity_logs_ts_idx on activity_logs (ts);
create index activity_logs_usage_problem on activity_logs ((meta ->> 'problem')) where action = 'ai_usage';
create index activity_logs_usage_session on activity_logs ((meta ->> 'session_id')) where action = 'ai_usage';

create table error_logs (
  id bigint generated always as identity primary key,
  ts timestamptz not null default now(),
  ref text not null,
  kind text not null default 'other',
  where_ text not null,
  message text not null,
  stack text,
  actor text not null default 'system' check (actor = any (array['teacher','student','system'])),
  teacher_id uuid references auth.users(id) on delete set null,
  link_id uuid references public_links(id) on delete set null,
  anon_id uuid,
  meta jsonb not null default '{}'::jsonb
);
create index error_logs_ref_idx on error_logs (ref);
create index error_logs_teacher_idx on error_logs (teacher_id, id desc);
create index error_logs_ts_idx on error_logs (ts);

-- ============ BẢO MẬT HÀNG (RLS) ============
-- Giáo viên chỉ ĐỌC được dữ liệu của mình. Mọi thao tác ghi và mọi thao tác của học sinh đi qua server bằng service-role.

alter table teacher_settings enable row level security;
alter table problems enable row level security;
alter table problem_versions enable row level security;
alter table public_links enable row level security;
alter table students enable row level security;
alter table chat_sessions enable row level security;
alter table messages enable row level security;
alter table session_evals enable row level security;
alter table session_analysis enable row level security;
alter table student_advice enable row level security;
alter table student_shares enable row level security;
alter table import_batches enable row level security;
alter table activity_logs enable row level security;
alter table error_logs enable row level security;

create policy own_settings on teacher_settings for select using (teacher_id = (select auth.uid()));
create policy own_problems on problems for select using (teacher_id = (select auth.uid()));
create policy own_problem_versions on problem_versions for select using (teacher_id = (select auth.uid()));
create policy own_links on public_links for select using (teacher_id = (select auth.uid()) and deleted_at is null);
create policy own_students on students for select using (teacher_id = (select auth.uid()) and deleted_at is null);
create policy own_sessions on chat_sessions for select using (link_id in (select id from public_links where teacher_id = (select auth.uid())));
create policy own_messages on messages for select using (session_id in (select s.id from chat_sessions s where s.link_id in (select id from public_links where teacher_id = (select auth.uid()))));
create policy own_evals on session_evals for select using (session_id in (select s.id from chat_sessions s where s.link_id in (select id from public_links where teacher_id = (select auth.uid()))));
create policy own_session_analysis on session_analysis for select using (exists (select 1 from chat_sessions s join public_links l on l.id = s.link_id where s.id = session_analysis.session_id and l.teacher_id = auth.uid()));
create policy own_advice on student_advice for select using (teacher_id = auth.uid());
create policy own_student_shares on student_shares for select using (teacher_id = (select auth.uid()));
create policy own_import_batches on import_batches for select using (teacher_id = (select auth.uid()));
create policy own_logs on activity_logs for select using (teacher_id = (select auth.uid()));
create policy own_errors on error_logs for select using (teacher_id = (select auth.uid()));

-- ============ CHẶN XÓA CỨNG ============

create function block_hard_delete() returns trigger language plpgsql as $$
begin
  raise exception 'Không xóa cứng dữ liệu (bảng %). Dùng xóa mềm (deleted_at).', tg_table_name;
end $$;

do $$
declare t text;
begin
  foreach t in array array['activity_logs','chat_sessions','messages','problems','public_links','session_analysis','session_evals','student_advice','student_shares','students','teacher_settings'] loop
    execute format('create trigger no_hard_delete before delete on %I for each row execute function block_hard_delete()', t);
    execute format('create trigger no_truncate before truncate on %I for each statement execute function block_hard_delete()', t);
  end loop;
end $$;

-- ============ LƯU BẢN CŨ CỦA ĐỀ KHI SỬA ============

create function keep_problem_version() returns trigger language plpgsql security definer set search_path to 'public' as $$
begin
  if new.content is distinct from old.content then
    insert into problem_versions(problem_id, teacher_id, version, content) values (old.id, old.teacher_id, old.version, old.content);
  end if;
  return new;
end $$;
create trigger problems_keep_version before update on problems for each row execute function keep_problem_version();

-- ============ HÀM ============

create function bump_visit(p_link uuid) returns void language sql as $$
  update public_links set visits = visits + 1 where id = p_link;
$$;

create function next_seq(p_link uuid) returns integer language sql as $$
  update public_links set session_count = session_count + 1 where id = p_link returning session_count;
$$;

create function rename_problem(p_id uuid, p_teacher uuid, p_code text) returns void language plpgsql set search_path to 'public' as $$
declare old_code text;
begin
  select code into old_code from problems where id = p_id and teacher_id = p_teacher and deleted_at is null for update;
  if old_code is null then raise exception 'Không tìm thấy đề.'; end if;
  if old_code = p_code then return; end if;
  if exists (select 1 from problems where teacher_id = p_teacher and code = p_code and deleted_at is null) then
    raise exception 'Mã đề % đã có. Chọn mã khác.', p_code;
  end if;
  update problems set code = p_code, content = jsonb_set(content, '{id}', to_jsonb(p_code)), version = version + 1, updated_at = now() where id = p_id;
  update public_links set problems_snapshot = (
      select jsonb_agg(case when e->>'id' = old_code then jsonb_set(e, '{id}', to_jsonb(p_code)) else e end order by ord)
      from jsonb_array_elements(problems_snapshot) with ordinality as t(e, ord))
    where teacher_id = p_teacher and problems_snapshot @> jsonb_build_array(jsonb_build_object('id', old_code));
  update chat_sessions set problem_code = p_code
    where problem_code = old_code and link_id in (select id from public_links where teacher_id = p_teacher);
end $$;

-- Phiên đang làm mà quá 2 giờ không có tin mới thì đánh dấu bỏ dở; nhật ký lỗi quá 30 ngày thì xóa.
create function sweep_abandoned() returns void language sql security definer set search_path to 'public' as $$
  update chat_sessions s
     set status = 'abandoned', ended_at = coalesce((select max(m.ts) from messages m where m.session_id = s.id), s.started_at)
   where s.status = 'active'
     and coalesce((select max(m.ts) from messages m where m.session_id = s.id), s.started_at) < now() - interval '2 hours';
  delete from error_logs where ts < now() - interval '30 days';
$$;

create function ai_usage_by_problem(days integer default 30)
returns table(problem text, kind text, sessions bigint, calls bigint, input bigint, cached bigint, output bigint, thoughts bigint)
language sql stable as $$
  select meta->>'problem',
    case when meta ? 'session_id' then 'session' else 'prep' end,
    count(distinct meta->>'session_id'), count(*),
    coalesce(sum((meta->>'input')::bigint), 0), coalesce(sum((meta->>'cached')::bigint), 0),
    coalesce(sum((meta->>'output')::bigint), 0), coalesce(sum((meta->>'thoughts')::bigint), 0)
  from public.activity_logs
  where action = 'ai_usage' and meta ? 'problem' and teacher_id = (select auth.uid()) and ts > now() - make_interval(days => days)
  group by 1, 2;
$$;

create function ai_usage_by_session(days integer default 30)
returns table(session_id uuid, calls bigint, input bigint, cached bigint, output bigint, thoughts bigint)
language sql stable as $$
  select (meta->>'session_id')::uuid, count(*),
    coalesce(sum((meta->>'input')::bigint), 0), coalesce(sum((meta->>'cached')::bigint), 0),
    coalesce(sum((meta->>'output')::bigint), 0), coalesce(sum((meta->>'thoughts')::bigint), 0)
  from public.activity_logs
  where action = 'ai_usage' and meta ? 'session_id' and teacher_id = (select auth.uid()) and ts > now() - make_interval(days => days)
  group by 1;
$$;

-- Thống kê theo đề của một liên kết: mỗi đề có những học sinh nào và trạng thái (ok = tự làm được, helped = có gợi ý, wrong, none)
create function link_problem_stats(p_link uuid) returns jsonb language sql stable as $$
  with per as (
    select s.problem_code,
      coalesce(s.student_code, 'anon:' || s.id::text) as k,
      (array_agg(s.student_code order by s.started_at desc))[1] as code,
      (array_agg(s.student_name order by s.started_at desc) filter (where s.student_name is not null))[1] as name,
      (array_agg(s.student_class order by s.started_at desc) filter (where s.student_class is not null))[1] as class,
      count(*) as sessions,
      case
        when bool_or(e.final_correct and s.revealed = 0) then 'ok'
        when bool_or(e.final_correct) then 'helped'
        when bool_or(e.session_id is not null) then 'wrong'
        else 'none' end as state
    from chat_sessions s left join session_evals e on e.session_id = s.id
    where s.link_id = p_link
    group by s.problem_code, coalesce(s.student_code, 'anon:' || s.id::text)
  )
  select coalesce(jsonb_agg(jsonb_build_object('code', problem_code, 'students', st) order by problem_code), '[]'::jsonb)
  from (
    select problem_code, jsonb_agg(jsonb_build_object('code', code, 'name', name, 'class', class, 'sessions', sessions, 'state', state)
      order by case state when 'ok' then 0 when 'helped' then 1 when 'wrong' then 2 else 3 end, name nulls last) as st
    from per group by problem_code
  ) t
$$;

-- Tổng hợp thống kê của một liên kết (4 tiêu chí, phân bố điểm, gợi ý, lỗi hay mắc, số phiên theo ngày)
create function link_summary(p_link uuid) returns jsonb language sql stable as $$
  with s as (select status, started_at from chat_sessions where link_id = p_link),
  e as (select ev.* from session_evals ev join chat_sessions c on c.id = ev.session_id where c.link_id = p_link)
  select jsonb_build_object(
    'sessions', (select count(*) from s),
    'done', (select count(*) filter (where status = 'done') from s),
    'rubric', (select jsonb_build_array(
      jsonb_build_object('name', 'Hiểu đề bài', 'value', round(coalesce(avg(identify), 0)::numeric, 1)),
      jsonb_build_object('name', 'Lập kế hoạch giải', 'value', round(coalesce(avg(plan), 0)::numeric, 1)),
      jsonb_build_object('name', 'Thực hiện kế hoạch', 'value', round(coalesce(avg(calculate), 0)::numeric, 1)),
      jsonb_build_object('name', 'Kiểm tra và đánh giá', 'value', round(coalesce(avg(explain), 0)::numeric, 1))) from e),
    'totalAvg', (select round(coalesce(avg(total), 0)::numeric, 1) from e),
    'correctPct', (select round(coalesce(avg(case when final_correct then 100 else 0 end), 0)::numeric) from e),
    'durationMin', (select round(coalesce(avg(duration_s), 0)::numeric / 60, 1) from e),
    'hintAvg', (select round(coalesce(avg(hint_count), 0)::numeric, 1) from e),
    'totalDist', (select coalesce(jsonb_agg(jsonb_build_object('name', total::text, 'value', n) order by total), '[]') from (select total, count(*) n from e group by total) t),
    'hintDist', (select coalesce(jsonb_agg(jsonb_build_object('name', 'Mức ' || max_hint_level, 'value', n) order by max_hint_level), '[]') from (select max_hint_level, count(*) n from e group by max_hint_level) t),
    'errors', (select coalesce(jsonb_agg(jsonb_build_object('name', x, 'value', n) order by n desc, x), '[]') from (select x, count(*) n from e, unnest(e.errors) x group by x) t),
    'daily', (select coalesce(jsonb_agg(jsonb_build_object('name', to_char(d, 'MM-DD'), 'value', n) order by d), '[]') from (select (started_at at time zone 'UTC')::date d, count(*) n from s group by 1) t),
    'likertAvg', (select round(avg(survey_likert)::numeric, 1) from e where survey_likert is not null),
    'likertN', (select count(survey_likert) from e)
  )
$$;

-- Hàm chỉ server (service-role) được gọi
revoke execute on function bump_visit(uuid), next_seq(uuid), rename_problem(uuid, uuid, text), sweep_abandoned() from public, anon, authenticated;
grant execute on function bump_visit(uuid), next_seq(uuid), rename_problem(uuid, uuid, text), sweep_abandoned() to service_role;

-- ============ VIEW THỐNG KÊ (chạy với quyền người gọi, nên tôn trọng RLS) ============

create view overview_stats with (security_invoker = true) as
  select (select count(*) from chat_sessions)::integer as sessions,
    (select count(*) from chat_sessions where status = 'done')::integer as done,
    (select count(*) from session_evals)::integer as evals,
    (select coalesce(avg(total), 0::numeric) from session_evals)::double precision as total_avg,
    (select coalesce(avg(case when final_correct then 100 else 0 end), 0::numeric) from session_evals)::double precision as correct_pct,
    (select coalesce(avg(duration_s), 0::numeric) from session_evals)::double precision as duration_s,
    (select coalesce(avg(hint_count), 0::numeric) from session_evals)::double precision as hint_avg;

create view error_counts with (security_invoker = true) as
  select x.x as name, count(*)::integer as value
  from session_evals, lateral unnest(session_evals.errors) x(x)
  group by x.x;

create view link_stats with (security_invoker = true) as
  select id as link_id, session_count as sessions,
    (select count(*) from chat_sessions s where s.link_id = l.id and s.status = 'done')::integer as done,
    (select coalesce(avg(e.total), 0::numeric) from session_evals e join chat_sessions s on s.id = e.session_id where s.link_id = l.id)::double precision as total_avg,
    visits
  from public_links l;

create view tag_stats with (security_invoker = true) as
  select l.tag, count(*)::integer as n,
    avg(e.total)::double precision as mean,
    coalesce(var_samp(e.total), 0::numeric)::double precision as var_samp,
    coalesce(stddev_pop(e.total), 0::numeric)::double precision as sd_pop
  from session_evals e
  join chat_sessions s on s.id = e.session_id
  join public_links l on l.id = s.link_id
  where l.tag is not null
  group by l.tag;

create view student_stats with (security_invoker = true) as
  select st.teacher_id, st.code as student_code,
    case when st.name is null then '{}'::text[] else array[st.name] end as names,
    count(s.id)::integer as sessions,
    count(e.session_id)::integer as evaluated,
    coalesce(avg(e.identify), 0::numeric)::double precision as identify,
    coalesce(avg(e.plan), 0::numeric)::double precision as plan,
    coalesce(avg(e.calculate), 0::numeric)::double precision as calculate,
    coalesce(avg(e.explain), 0::numeric)::double precision as explain,
    coalesce(avg(e.total), 0::numeric)::double precision as total_avg,
    coalesce(avg(case when e.final_correct then 100 else 0 end), 0::numeric)::double precision as correct_pct,
    coalesce(avg(e.hint_count), 0::numeric)::double precision as hint_avg,
    coalesce(max(s.started_at), st.last_seen_at) as last_at,
    st.class as student_class
  from students st
  left join (chat_sessions s join public_links l on l.id = s.link_id) on l.teacher_id = st.teacher_id and s.student_code = st.code
  left join session_evals e on e.session_id = s.id
  group by st.teacher_id, st.code, st.name, st.class, st.last_seen_at;

-- ============ KHO ẢNH HÌNH VẼ CỦA ĐỀ (công khai: ai có đường dẫn đều xem được) ============

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('figures', 'figures', true, 1048576, array['image/png','image/jpeg','image/webp'])
on conflict (id) do nothing;
