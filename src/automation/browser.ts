import puppeteer, { Browser } from "puppeteer";

export async function launchBrowser(): Promise<Browser> {
  const browser = await puppeteer.launch({
    headless: false,
    defaultViewport: {
      width: 1366,
      height: 768,
    },
  });

  return browser;
}