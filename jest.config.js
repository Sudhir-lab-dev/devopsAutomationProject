module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",

  collectCoverage: true,

  coverageDirectory: "coverage",

  collectCoverageFrom: [
    "src/**/*.ts",
    "!src/tests/**"
  ],

  coverageReporters: [
    "text",
    "lcov"
  ],

  reporters: [
    "default",
    [
      "jest-junit",
      {
        outputDirectory: "reports/junit",
        outputName: "junit.xml"
      }
    ]
  ]
};