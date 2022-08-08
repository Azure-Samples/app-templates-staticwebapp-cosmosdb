const { CosmosClient } = require("@azure/cosmos");
const fs = require("fs")

const cosmosConnectionString = process.env.COSMOS_CONNECTION_STRING;
const sampleItemsFile = "sampledata/cosmosdb.items.json"
const sampleListsFile = "sampledata/cosmosdb.lists.json"

const databaseId = "ToDoList";
const itemsContainerId = "Items";
const listsContainerId = "Lists";

const client = new CosmosClient(cosmosConnectionString);

async function run() {
    // Read the sample data from file
    const itemDefs = JSON.parse(fs.readFileSync(sampleItemsFile, "utf8"));
    const listDefs = JSON.parse(fs.readFileSync(sampleListsFile, "utf8"));

    let lists = await client.database(databaseId).container(listsContainerId).items;
    let existingLists = await lists.readAll().fetchAll();

    // We only insert items if the container is empty
    if(existingLists.resources.length == 0) {
        await Promise.all(listDefs.map((itemDef) => lists.create(itemDef)));
        console.log(listDefs.length + " lists created");
    }

    let listItems = await client.database(databaseId).container(itemsContainerId).items;
    let existingItems = await listItems.readAll().fetchAll();

    // We only insert items if the container is empty
    if(existingItems.resources.length == 0) {
        await Promise.all(itemDefs.map((itemDef) => listItems.create(itemDef)));
        console.log(itemDefs.length + " items created");
    }
}
run();