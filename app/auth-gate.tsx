"use client";

import { useEffect, useState } from "react";
import { AuthView, NeonAuthUIProvider, UserButton } from "@neondatabase/neon-js/auth/react/ui";
import { LockKeyhole } from "lucide-react";
import { neon } from "@/lib/neon";

const AUTH_PATHS = new Set([
  "sign-in",
  "sign-up",
  "forgot-password",
  "reset-password",
  "verify-email",
  "callback",
]);

function currentAuthPath() {
  if (typeof window === "undefined") return "sign-in";
  const path = window.location.pathname.split("/").filter(Boolean);
  return path[0] === "auth" && AUTH_PATHS.has(path[1]) ? path[1] : "sign-in";
}

export function AuthGate({ children }: { children: React.ReactNode }) {
  return (
    <NeonAuthUIProvider authClient={neon.auth} redirectTo="/">
      <AuthBoundary>{children}</AuthBoundary>
    </NeonAuthUIProvider>
  );
}

function AuthBoundary({ children }: { children: React.ReactNode }) {
  const session = neon.auth.useSession();
  const [authPath, setAuthPath] = useState(currentAuthPath);

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

  return <><div className="auth-user-button"><UserButton /></div>{children}</>;
}
