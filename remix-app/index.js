const { createRequestHandler } = require("@remix-run/aws-lambda");

exports.handler = createRequestHandler({
  build: require("./build"),
});
