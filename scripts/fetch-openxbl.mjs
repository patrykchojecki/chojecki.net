import { readFileSync } from "node:fs";
import { mkdir, mkdtemp, rename, rm, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

import { fetchOpenXblData } from "./openxbl-client.mjs";
import { normalizeOpenXblData } from "./openxbl-normalizer.mjs";

export { fetchOpenXblData, normalizeOpenXblData };

const OUTPUT_PATH = resolve(
  dirname(fileURLToPath(import.meta.url)),
  "../_data/xbox.json"
);

async function main() {
  const apiKey = (
    process.argv.includes("--stdin")
      ? readFileSync(0, "utf8")
      : process.env.OPENXBL_API_KEY || ""
  ).trim();

  if (!apiKey) {
    throw new Error(
      "OPENXBL_API_KEY is not set. Add it as a GitHub Actions secret before deploying."
    );
  }

  const data = await fetchOpenXblData(apiKey);
  const outputDirectory = dirname(OUTPUT_PATH);
  await mkdir(outputDirectory, { recursive: true });
  const temporaryDirectory = await mkdtemp(join(outputDirectory, ".xbox-"));
  const temporaryPath = join(temporaryDirectory, "xbox.json");
  try {
    await writeFile(temporaryPath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
    await rename(temporaryPath, OUTPUT_PATH);
  } finally {
    await rm(temporaryDirectory, { recursive: true, force: true });
  }
  process.stdout.write(
    `Wrote Xbox activity for ${data.profile.gamertag} to _data/xbox.json\n`
  );
}

const invokedDirectly =
  process.argv[1] &&
  import.meta.url === pathToFileURL(resolve(process.argv[1])).href;

if (invokedDirectly) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
