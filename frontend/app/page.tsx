"use client";
import "@/app/globals.css";

import ButtonSliderSection from "./_components/ButtonSliderSection";
import { SearchBar, SearchBarSection } from "./_components/SearchBarSection";
import TableSection from "./_components/TableSection";
import ClientOnly from "@/lib/ClientOnly";
import { useSelectedSong } from "@/lib/hooks";
import { useEffect } from "react";

function NoSongSelected() {
  return (
    <main className="flex justify-center items-center h-1/2">
      <div className="flex flex-col justify-center items-center w-1/2 gap-4">
        <h1>First, please select a song to generate a recommendation for!</h1>
        <SearchBar />
      </div>
    </main>
  );
}

export function App() {
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("resetState") !== "1") return;

    localStorage.removeItem("selectedSong");
    localStorage.removeItem("playlist");
    localStorage.removeItem("yearFilter.startYear");
    localStorage.removeItem("yearFilter.endYear");

    Object.keys(localStorage).forEach((key) => {
      if (key.startsWith("slider.")) {
        localStorage.removeItem(key);
      }
    });

    params.delete("resetState");
    const queryString = params.toString();
    const targetUrl = queryString
      ? `${window.location.pathname}?${queryString}`
      : window.location.pathname;

    window.location.replace(targetUrl);
  }, []);

  const { selectedSong } = useSelectedSong();
  if (selectedSong == undefined) {
    return <NoSongSelected />;
  }

  return (
    <main className="flex flex-col justify-center items-center">
      <ButtonSliderSection />
      <SearchBarSection />
      <TableSection />
    </main>
  );
}

export default function Page() {
  return (
    <ClientOnly>
      <App />
    </ClientOnly>
  );
}
