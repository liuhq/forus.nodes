import { Welcome } from "../welcome/welcome"

export function meta() {
  return [
    { title: "《11月5日》 | Forus" },
    { name: "description", content: "Forus 论坛中的七日分支叙事。" },
  ]
}

export default function Home() {
  return <Welcome />
}
