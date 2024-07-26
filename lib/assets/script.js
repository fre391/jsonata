console.log("Adding script for JSONata library");
const script = document.createElement("script");
script.type = "text/javascript";
script.src = "https://cdn.jsdelivr.net/npm/jsonata/jsonata.min.js";
document.head.appendChild(script);

let data = "";

async function initialize(json) {
  data = JSON.parse(JSON.stringify(json)); 
  console.log("(JSONata) data: " + data );
}

async function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function query(id, jql) {
  while (typeof jsonata !== 'function') {
    await delay(100);
  }
  
  console.log("(JSONata) data: " + JSON.stringify(data));
  console.log("(JSONata) jql: " + jql);

  let result = { id: id, value: "", error: "" };

  try {
    let queryResult = await jsonata(jql).evaluate(data);
    result.value = JSON.stringify(queryResult);
    if (result.value == undefined) result.value = "undefined";
    console.log("(JSONata) result: " + result.value);
  } catch (error) {
    result.error = error.message || error.toString();
    console.log(error);
  } finally {
    await window.flutter_inappwebview.callHandler("json", result);
  }
}

