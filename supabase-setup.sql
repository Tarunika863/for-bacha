-- Run this entire file in Supabase -> SQL Editor -> New query.
-- IMPORTANT: replace BOTH occurrences of YOUR-PRIVATE-EMAIL@example.com below first.

create table if not exists public.responses (
  visitor_id text primary key,
  visitor_token text not null,
  q jsonb not null default '{}'::jsonb,
  ev jsonb not null default '[]'::jsonb,
  first bigint not null,
  last bigint not null
);

alter table public.responses enable row level security;

-- The browser can only call these two functions with its own random visitor ID
-- and a separate unguessable token. Anonymous users receive no direct table access.
revoke all on public.responses from anon;
grant select, delete on public.responses to authenticated;

drop policy if exists "Owner can read responses" on public.responses;
create policy "Owner can read responses"
on public.responses for select to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) =
  lower('YOUR-PRIVATE-EMAIL@example.com')
);

drop policy if exists "Owner can delete responses" on public.responses;
create policy "Owner can delete responses"
on public.responses for delete to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) =
  lower('YOUR-PRIVATE-EMAIL@example.com')
);

create or replace function public.get_my_response(
  p_visitor_id text,
  p_visitor_token text
) returns jsonb
language sql
security definer
set search_path = public
as $$
  select jsonb_build_object('q', q, 'ev', ev, 'first', first)
  from public.responses
  where visitor_id = p_visitor_id
    and visitor_token = p_visitor_token
  limit 1;
$$;

create or replace function public.save_my_response(
  p_visitor_id text,
  p_visitor_token text,
  p_q jsonb,
  p_ev jsonb,
  p_first bigint,
  p_last bigint
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.responses(visitor_id, visitor_token, q, ev, first, last)
  values (p_visitor_id, p_visitor_token, coalesce(p_q, '{}'::jsonb),
          coalesce(p_ev, '[]'::jsonb), p_first, p_last)
  on conflict (visitor_id) do update
    set q = excluded.q,
        ev = excluded.ev,
        last = excluded.last
    where public.responses.visitor_token = excluded.visitor_token;
end;
$$;

revoke all on function public.get_my_response(text,text) from public;
revoke all on function public.save_my_response(text,text,jsonb,jsonb,bigint,bigint) from public;
grant execute on function public.get_my_response(text,text) to anon, authenticated;
grant execute on function public.save_my_response(text,text,jsonb,jsonb,bigint,bigint) to anon, authenticated;
