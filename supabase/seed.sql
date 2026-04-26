insert into public.localities (name, commute_score, safety_score, affordability_score, notes)
values
  ('Indiranagar', 8, 7, 4, 'Central, high rent, strong food and metro access.'),
  ('HSR Layout', 7, 7, 6, 'Startup-friendly, good cafes, mixed commute times.'),
  ('Whitefield', 6, 6, 7, 'Office-heavy, improving metro access, longer cross-city travel.')
on conflict do nothing;

insert into public.kannada_lessons (title, phrase, transliteration, meaning)
values
  ('Greeting', 'ನಮಸ್ಕಾರ', 'Namaskara', 'Hello'),
  ('Auto Ride', 'ಎಷ್ಟು ಆಗುತ್ತದೆ?', 'Eshtu aguttade?', 'How much will it cost?')
on conflict do nothing;

insert into public.quests (title, description, points)
values
  ('Take your first metro ride', 'Use Namma Metro and record the route you took.', 25),
  ('Learn one Kannada phrase', 'Complete today''s Kannada lesson.', 10)
on conflict do nothing;
