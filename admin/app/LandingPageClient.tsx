"use client";

import Image from "next/image";
import { useActionState } from "react";
import { getAreaMatch, type LandingLeadState } from "@/lib/landingActions";

const initialState: LandingLeadState = {
  ok: false,
  matches: []
};

const fitStyles = {
  green: "bg-emerald-700 text-white",
  yellow: "bg-amber-500 text-neutral-950",
  red: "bg-rose-700 text-white"
};

export function LandingPageClient() {
  const [state, formAction, isPending] = useActionState(getAreaMatch, initialState);

  return (
    <main className="min-h-screen bg-[#f8f3e8] text-[#16251f]">
      <section className="relative min-h-screen overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_18%_18%,rgba(18,99,74,0.20),transparent_30%),linear-gradient(130deg,#fbf4e4_0%,#f6dfbf_48%,#d7eadb_100%)]" />
        <div className="absolute inset-x-0 bottom-0 h-40 bg-gradient-to-t from-[#f8f3e8] to-transparent" />
        <div className="relative mx-auto grid min-h-screen max-w-7xl gap-10 px-5 py-8 lg:grid-cols-[0.92fr_1.08fr] lg:px-10">
          <div className="flex flex-col justify-between gap-10 pb-4 pt-4">
            <nav className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Image
                  alt="NammaCircle"
                  className="rounded-lg"
                  height={44}
                  src="/app-icon.png"
                  width={44}
                />
                <span className="text-xl font-semibold tracking-tight">NammaCircle</span>
              </div>
              <a className="text-sm font-medium text-[#235c47] hover:text-[#123b2c]" href="/dashboard">
                Admin
              </a>
            </nav>

            <div className="max-w-2xl animate-[fadeIn_700ms_ease-out]">
              <p className="text-sm font-semibold uppercase tracking-[0.22em] text-[#2d6b52]">
                Bengaluru settling guide
              </p>
              <h1 className="mt-5 max-w-3xl text-5xl font-semibold leading-[0.96] tracking-tight text-[#101b16] md:text-7xl">
                Moving to Bangalore? Find where to live before you pay deposit.
              </h1>
              <p className="mt-6 max-w-xl text-lg leading-8 text-[#435149]">
                Get a deterministic area match using your office location, budget, commute tolerance, and lifestyle signals.
              </p>
              <a
                className="mt-8 inline-flex rounded-full bg-[#123b2c] px-6 py-3 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:bg-[#0c2a1f]"
                href="#area-match"
              >
                Get your free area match
              </a>
            </div>

            <div className="relative h-56 overflow-hidden rounded-lg border border-[#cfb98f]/60 bg-[#fff8eb]/50 shadow-sm md:h-72">
              <Image
                alt="NammaCircle area matching preview"
                className="h-full w-full object-cover opacity-95"
                fill
                priority
                src="/feature-icons.png"
              />
            </div>
          </div>

          <div className="flex items-center pb-10 pt-6 lg:pt-20" id="area-match">
            <section className="w-full rounded-lg border border-[#d3bd92] bg-[#fffaf0]/88 p-5 shadow-2xl shadow-[#6e5a35]/10 backdrop-blur md:p-8">
              <div className="mb-7">
                <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[#2d6b52]">
                  Free area match
                </p>
                <h2 className="mt-2 text-3xl font-semibold tracking-tight">Tell us what matters.</h2>
              </div>

              <form action={formAction} className="grid gap-4">
                <label className="grid gap-2 text-sm font-medium">
                  Office location
                  <input
                    className="rounded-lg border border-[#d8c49e] bg-white px-4 py-3 outline-none transition focus:border-[#26664f] focus:ring-4 focus:ring-[#26664f]/10"
                    name="office_location"
                    placeholder="Bellandur, MG Road, Whitefield..."
                    required
                  />
                </label>

                <div className="grid gap-4 md:grid-cols-2">
                  <label className="grid gap-2 text-sm font-medium">
                    Budget
                    <input
                      className="rounded-lg border border-[#d8c49e] bg-white px-4 py-3 outline-none transition focus:border-[#26664f] focus:ring-4 focus:ring-[#26664f]/10"
                      name="budget"
                      placeholder="25000-45000"
                      required
                    />
                  </label>
                  <label className="grid gap-2 text-sm font-medium">
                    Commute tolerance
                    <input
                      className="rounded-lg border border-[#d8c49e] bg-white px-4 py-3 outline-none transition focus:border-[#26664f] focus:ring-4 focus:ring-[#26664f]/10"
                      min={10}
                      name="commute_tolerance"
                      placeholder="45"
                      type="number"
                    />
                  </label>
                </div>

                <label className="grid gap-2 text-sm font-medium">
                  Lifestyle tags
                  <input
                    className="rounded-lg border border-[#d8c49e] bg-white px-4 py-3 outline-none transition focus:border-[#26664f] focus:ring-4 focus:ring-[#26664f]/10"
                    name="lifestyle_tags"
                    placeholder="cafes, quiet, food, metro, budget"
                  />
                </label>

                <label className="grid gap-2 text-sm font-medium">
                  Phone/email optional
                  <input
                    className="rounded-lg border border-[#d8c49e] bg-white px-4 py-3 outline-none transition focus:border-[#26664f] focus:ring-4 focus:ring-[#26664f]/10"
                    name="contact"
                    placeholder="you@example.com"
                  />
                </label>

                {state.error ? (
                  <p className="rounded-lg bg-rose-50 px-4 py-3 text-sm text-rose-700">{state.error}</p>
                ) : null}

                <button
                  className="mt-1 rounded-full bg-[#123b2c] px-6 py-4 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:bg-[#0c2a1f] disabled:cursor-not-allowed disabled:opacity-60"
                  disabled={isPending}
                  type="submit"
                >
                  {isPending ? "Matching..." : "Get your free area match"}
                </button>
              </form>

              {state.matches.length > 0 ? (
                <section className="mt-8 animate-[fadeIn_450ms_ease-out] border-t border-[#d8c49e] pt-6">
                  <div className="flex items-end justify-between gap-4">
                    <div>
                      <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[#2d6b52]">
                        Your top 3
                      </p>
                      <h3 className="mt-1 text-2xl font-semibold">Deterministic matches</h3>
                    </div>
                    <p className="text-sm text-[#66736c]">No AI guesses.</p>
                  </div>
                  <div className="mt-5 grid gap-3">
                    {state.matches.map((match, index) => (
                      <article
                        className="rounded-lg border border-[#ddc9a4] bg-white/80 p-4 transition hover:-translate-y-0.5 hover:border-[#2d6b52]"
                        key={match.locality_id}
                      >
                        <div className="flex items-start justify-between gap-4">
                          <div>
                            <p className="text-xs font-semibold text-[#66736c]">#{index + 1}</p>
                            <h4 className="mt-1 text-xl font-semibold">{match.name}</h4>
                            <p className="mt-2 text-sm leading-6 text-[#59665f]">{match.top_reasons[0]}</p>
                          </div>
                          <span className={`rounded-full px-3 py-1 text-xs font-semibold ${fitStyles[match.fit]}`}>
                            {match.fit}
                          </span>
                        </div>
                        <p className="mt-3 text-xs text-[#66736c]">
                          Score {match.score}/100 · Confidence {match.confidence_level}
                        </p>
                      </article>
                    ))}
                  </div>
                  <div className="mt-6 rounded-lg bg-[#123b2c] p-5 text-white">
                    <h4 className="text-lg font-semibold">Next step</h4>
                    <p className="mt-2 text-sm leading-6 text-white/82">
                      Download the iOS app when it opens, or join the waitlist to get your report and early access.
                    </p>
                  </div>
                </section>
              ) : null}
            </section>
          </div>
        </div>
      </section>
    </main>
  );
}
