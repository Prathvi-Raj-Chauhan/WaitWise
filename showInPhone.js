const express = require("express");
const app = express();

app.use(express.static("public"));

app.listen(9091, "0.0.0.0", () => {
    console.log("Server running");
});