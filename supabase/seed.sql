with locality_seed(name, slug, description, longitude, latitude) as (
  values
    ('HSR Layout', 'hsr-layout', 'Planned residential and startup-friendly area with cafes, parks, and access to ORR offices.', 77.6476, 12.9121),
    ('Bellandur', 'bellandur', 'Outer Ring Road tech corridor locality with office access and traffic tradeoffs.', 77.6762, 12.9352),
    ('Whitefield', 'whitefield', 'Large eastern tech hub with gated communities, malls, and improving metro connectivity.', 77.7500, 12.9698),
    ('Marathahalli', 'marathahalli', 'Busy rental hub between ORR, Whitefield, and HAL-side offices.', 77.6974, 12.9569),
    ('Koramangala', 'koramangala', 'Central social and startup neighborhood with strong food, nightlife, and high rents.', 77.6245, 12.9352),
    ('Indiranagar', 'indiranagar', 'Premium east-central locality with metro, restaurants, and high rent pressure.', 77.6412, 12.9784),
    ('BTM Layout', 'btm-layout', 'Budget-friendly south Bengaluru locality with good bus access and student density.', 77.6101, 12.9166),
    ('JP Nagar', 'jp-nagar', 'Established south Bengaluru residential area with calm streets and metro access nearby.', 77.5857, 12.9063),
    ('Electronic City', 'electronic-city', 'Southern tech hub with lower rents and longer commutes to central Bengaluru.', 77.6603, 12.8452),
    ('Hebbal', 'hebbal', 'North Bengaluru gateway with airport access, lake area, and growing office clusters.', 77.5913, 13.0358)
)
insert into public.localities (name, slug, city, description, center)
select name, slug, 'Bengaluru', description, st_setsrid(st_makepoint(longitude, latitude), 4326)::geography
from locality_seed
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  center = excluded.center,
  updated_at = now();

with score_seed(slug, rent_score, commute_score, food_score, social_life_score, quiet_score, safety_confidence_score, newcomer_friendliness_score, kannada_dependency_score, broker_risk_score, water_reliability_score, confidence_level) as (
  values
    ('hsr-layout', 6, 7, 8, 7, 6, 7, 8, 4, 5, 6, 'medium'),
    ('bellandur', 5, 8, 6, 5, 4, 5, 6, 4, 6, 4, 'medium'),
    ('whitefield', 7, 6, 7, 6, 6, 6, 7, 4, 5, 6, 'medium'),
    ('marathahalli', 7, 7, 6, 5, 4, 5, 6, 5, 7, 5, 'medium'),
    ('koramangala', 4, 7, 10, 10, 4, 7, 8, 3, 6, 6, 'high'),
    ('indiranagar', 3, 8, 10, 9, 5, 7, 8, 3, 6, 6, 'high'),
    ('btm-layout', 8, 6, 7, 6, 5, 5, 7, 5, 6, 5, 'medium'),
    ('jp-nagar', 7, 6, 7, 5, 8, 7, 7, 5, 4, 7, 'medium'),
    ('electronic-city', 9, 5, 5, 4, 7, 6, 6, 5, 4, 6, 'medium'),
    ('hebbal', 6, 7, 6, 5, 7, 6, 6, 5, 5, 6, 'low')
)
insert into public.locality_scores (
  locality_id,
  rent_score,
  commute_score,
  food_score,
  social_life_score,
  quiet_score,
  safety_confidence_score,
  newcomer_friendliness_score,
  kannada_dependency_score,
  broker_risk_score,
  water_reliability_score,
  last_verified_at,
  confidence_level
)
select
  localities.id,
  score_seed.rent_score,
  score_seed.commute_score,
  score_seed.food_score,
  score_seed.social_life_score,
  score_seed.quiet_score,
  score_seed.safety_confidence_score,
  score_seed.newcomer_friendliness_score,
  score_seed.kannada_dependency_score,
  score_seed.broker_risk_score,
  score_seed.water_reliability_score,
  now(),
  score_seed.confidence_level
from score_seed
join public.localities on localities.slug = score_seed.slug
on conflict (locality_id) do update set
  rent_score = excluded.rent_score,
  commute_score = excluded.commute_score,
  food_score = excluded.food_score,
  social_life_score = excluded.social_life_score,
  quiet_score = excluded.quiet_score,
  safety_confidence_score = excluded.safety_confidence_score,
  newcomer_friendliness_score = excluded.newcomer_friendliness_score,
  kannada_dependency_score = excluded.kannada_dependency_score,
  broker_risk_score = excluded.broker_risk_score,
  water_reliability_score = excluded.water_reliability_score,
  last_verified_at = excluded.last_verified_at,
  confidence_level = excluded.confidence_level;

with baseline_seed(slug, bhk, median_rent, deposit_months, sample_size, confidence_level) as (
  values
    ('hsr-layout', '1BHK', 26000, 6, 12, 'medium'),
    ('hsr-layout', '2BHK', 43000, 6, 18, 'medium'),
    ('bellandur', '1BHK', 28000, 6, 10, 'medium'),
    ('bellandur', '2BHK', 46000, 7, 16, 'medium'),
    ('whitefield', '1BHK', 24000, 6, 14, 'medium'),
    ('whitefield', '2BHK', 39000, 6, 20, 'medium'),
    ('marathahalli', '1BHK', 22000, 6, 9, 'medium'),
    ('marathahalli', '2BHK', 36000, 6, 13, 'medium'),
    ('koramangala', '1BHK', 32000, 7, 18, 'high'),
    ('koramangala', '2BHK', 56000, 8, 22, 'high'),
    ('indiranagar', '1BHK', 35000, 8, 16, 'high'),
    ('indiranagar', '2BHK', 62000, 8, 20, 'high'),
    ('btm-layout', '1BHK', 19000, 5, 11, 'medium'),
    ('btm-layout', '2BHK', 32000, 6, 13, 'medium'),
    ('jp-nagar', '1BHK', 21000, 5, 10, 'medium'),
    ('jp-nagar', '2BHK', 35000, 6, 14, 'medium'),
    ('electronic-city', '1BHK', 17000, 5, 12, 'medium'),
    ('electronic-city', '2BHK', 29000, 5, 16, 'medium'),
    ('hebbal', '1BHK', 24000, 6, 7, 'low'),
    ('hebbal', '2BHK', 41000, 6, 9, 'low')
)
insert into public.rent_baselines (
  locality_id,
  bhk,
  median_rent,
  deposit_months,
  sample_size,
  confidence_level,
  source_note
)
select
  localities.id,
  baseline_seed.bhk,
  baseline_seed.median_rent,
  baseline_seed.deposit_months,
  baseline_seed.sample_size,
  baseline_seed.confidence_level,
  'Seeded MVP baseline for deterministic fallback checks.'
from baseline_seed
join public.localities on localities.slug = baseline_seed.slug
on conflict (locality_id, bhk) do update set
  median_rent = excluded.median_rent,
  deposit_months = excluded.deposit_months,
  sample_size = excluded.sample_size,
  confidence_level = excluded.confidence_level,
  source_note = excluded.source_note,
  updated_at = now();

insert into public.locality_signals (locality_id, signal_type, source_type, summary, confidence_level, verified_at)
select id, 'commute', 'admin', 'MVP seed signal based on broad commute access and neighborhood positioning.', 'medium', now()
from public.localities
where slug in ('hsr-layout', 'whitefield', 'indiranagar', 'electronic-city')
on conflict do nothing;

with lesson_rows(title, situation, difficulty, sort_order) as (
  values
    ('Auto Basics', 'Taking an auto or cab', 'beginner', 1),
    ('Shop Talk', 'Buying groceries or essentials', 'beginner', 2),
    ('Neighbor Greeting', 'Meeting neighbors and guards', 'beginner', 3)
),
inserted_lessons as (
  insert into public.kannada_lessons (title, situation, difficulty, sort_order, is_published)
  select title, situation, difficulty, sort_order, true
  from lesson_rows
  on conflict do nothing
  returning id, title
)
insert into public.kannada_phrases (lesson_id, kannada_text, transliteration, english_meaning, usage_note, sort_order)
select lesson.id, phrase.kannada_text, phrase.transliteration, phrase.english_meaning, phrase.usage_note, phrase.sort_order
from (
  select id, title from inserted_lessons
  union
  select id, title from public.kannada_lessons where title in ('Auto Basics', 'Shop Talk', 'Neighbor Greeting')
) lesson
join (
  values
    ('Auto Basics', 'ಎಷ್ಟು ಆಗುತ್ತದೆ?', 'Eshtu aguttade?', 'How much will it cost?', 'Useful before starting an auto ride.', 1),
    ('Auto Basics', 'ಇಲ್ಲಿ ನಿಲ್ಲಿಸಿ', 'Illi nillisi', 'Stop here.', 'Use when you are near your destination.', 2),
    ('Shop Talk', 'ಇದು ಎಷ್ಟು?', 'Idu eshtu?', 'How much is this?', 'Simple price question in shops.', 1),
    ('Shop Talk', 'ಸ್ವಲ್ಪ ಕಡಿಮೆ ಮಾಡಿ', 'Swalpa kadime maadi', 'Please reduce it a little.', 'Polite bargaining phrase.', 2),
    ('Neighbor Greeting', 'ನಮಸ್ಕಾರ', 'Namaskara', 'Hello.', 'Safe greeting for most situations.', 1),
    ('Neighbor Greeting', 'ನಾನು ಹೊಸದಾಗಿ ಬಂದಿದ್ದೇನೆ', 'Naanu hosadagi bandiddene', 'I have newly moved here.', 'Helpful with neighbors or building staff.', 2)
) as phrase(title, kannada_text, transliteration, english_meaning, usage_note, sort_order)
on phrase.title = lesson.title
on conflict do nothing;

insert into public.quests (title, description, quest_type, locality_id, points, is_active, sponsor_name)
values
  ('Learn one Kannada phrase', 'Complete today''s Kannada lesson and use the phrase once.', 'lesson', null, 10, true, null),
  ('Compare two localities', 'Check scores for two areas near your office and save your preference.', 'locality_research', null, 20, true, null),
  ('Metro confidence run', 'Take a short metro ride and write one tip for another newcomer.', 'city_exploration', null, 25, true, null),
  ('Rent sanity check', 'Run a rent fairness check before speaking to a broker.', 'rent_check', null, 15, true, null)
on conflict do nothing;

insert into public.forum_posts (user_id, locality_id, title, body, category, urgency, moderation_status)
select
  null,
  localities.id,
  seed.title,
  seed.body,
  seed.category,
  'normal',
  'approved'
from (
  values
    ('hsr-layout', 'Is HSR good for a first month in Bengaluru?', 'I work near Bellandur and want cafes, gyms, and manageable commute. Is HSR a good first area?', 'locality'),
    ('whitefield', 'Whitefield deposit norms for 1BHK?', 'Seeing 5 to 10 month deposits depending on the building. What should I treat as normal?', 'rent'),
    ('btm-layout', 'BTM vs JP Nagar for lower budget?', 'Looking for a quieter place under a tighter budget. Which one is easier for newcomers?', 'locality')
) as seed(slug, title, body, category)
join public.localities on localities.slug = seed.slug
on conflict do nothing;
