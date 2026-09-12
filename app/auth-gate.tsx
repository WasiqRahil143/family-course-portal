"use client";

import { useEffect, useState } from "react";
import { AuthView, NeonAuthUIProvider } from "@neondatabase/neon-js/auth/react/ui";
import { LockKeyhole, LogOut } from "lucide-react";
import { neon } from "@/lib/neon";

const AUTH_PATHS = new Set([
  "sign-in",
  "sign-up",
  "forgot-password",
  "reset-password",
  "email-verification",
  "email-otp",
  "magic-link",
  "recover-account",
  "sign-out",
  "two-factor",
  "accept-invitation",
  "callback",
]);

function currentAuthPath() {
  if (typeof window === "undefined") return "sign-in";
  const path = window.location.pathname.split("/").filter(Boolean);
  return path[0] === "auth" && AUTH_PATHS.has(path[1]) ? path[1] : "sign-in";
}

export function AuthGate({ children }: { children: React.ReactNode }) {
  return (
    <NeonAuthUIProvider
      authClient={neon.auth}
      redirectTo="/"
      credentials={{ confirmPassword: true }}
      emailVerification={{ otp: true }}
    >
      <AuthBoundary>{children}</AuthBoundary>
    </NeonAuthUIProvider>
  );
}

function AuthBoundary({ children }: { children: React.ReactNode }) {
  const session = neon.auth.useSession();
  const [authPath, setAuthPath] = useState(currentAuthPath);
  const [signingOut, setSigningOut] = useState(false);

  useEffect(() => {
    const syncPath = () => setAuthPath(currentAuthPath());
    window.addEventListener("popstate", syncPath);
    return () => window.removeEventListener("popstate", syncPath);
  }, []);

  if (session.isPending) {
    return <main className="auth-loading" aria-label="Anmeldung wird geprüft"><span /></main>;
  }

  if (!session.data) {
    return (
      <main className="auth-shell">
        <section className="auth-brand-panel">
          <div className="brand auth-brand"><span>TR</span><div>Train With<br /><b>Rahil</b></div></div>
          <div>
            <small>SCHOOL CLUB PLATFORM</small>
            <h1>Alles rund um den Kurs. Einfach an einem Ort.</h1>
            <p>Termine, Abwesenheiten, Zahlungen und Fortschritte sicher verwalten.</p>
          </div>
          <p className="auth-trust"><LockKeyhole size={18} /> Persönliche Kursdaten sind erst nach der Anmeldung sichtbar.</p>
        </section>
        <section className="auth-form-panel">
          <div className="auth-card"><AuthView path={authPath as never} /></div>
        </section>
      </main>
    );
  }

  const signOut = async () => {
    if (signingOut) return;
    setSigningOut(true);
    try {
      await neon.auth.signOut();
      window.location.replace("/auth/sign-in");
    } catch {
      setSigningOut(false);
    }
  };

  return <><button className="auth-sign-out" onClick={signOut} disabled={signingOut}><LogOut size={17}/>{signingOut ? "Wird abgemeldet…" : "Abmelden"}</button>{children}</>;
}
