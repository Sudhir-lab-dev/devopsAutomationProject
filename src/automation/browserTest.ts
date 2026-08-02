import { runAutomation } from "../services/automation.service";

async function main() {
  const result = await runAutomation({
    firstName: "Sudhir",
    lastName: "Mhaske",
    email: "sudhir@example.com",
  });

  console.log(result);
}

main().catch(console.error);