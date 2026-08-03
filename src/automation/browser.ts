import puppeteer, { Browser } from "puppeteer";

export async function launchBrowser(): Promise<Browser> {
  const browser = await puppeteer.launch({
    headless: true,
    defaultViewport: {
      width: 1366,
      height: 768,
    },
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox"
    ]
  });

  return browser;
}