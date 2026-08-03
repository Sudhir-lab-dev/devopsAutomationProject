import request from "supertest";
import app from "./testApp";

describe("Health API", () => {
    it("should return 200", async () => {
        const res = await request(app).get("/api/health");

        expect(res.status).toBe(200);
    });
});