import { redirect } from "next/navigation";
import { getDateKey } from "@/lib/engine";

export default function Home() {
  redirect(`/today/${getDateKey(new Date())}`);
}
