import { CosmosClient, Item } from "@azure/cosmos";

const client = new CosmosClient(process.env.CosmosKey);

const resolvers = {
    List: {
        async items(parent) {
            let results = await client
                .database("ToDoList")
                .container("Items")
                .items.query({
                    query: "SELECT * FROM c WHERE c.listId=@listId",
                    parameters: [
                        {
                            name: "@listId",
                            value: parent.id
                        }
                    ]
                })
                .fetchAll();

            return results.resources;
        }
    },
    Query: {
        async Lists(_) {
            let results = await client
            .database("ToDoList")
            .container("Lists")
            .items.query({
                query: "SELECT * FROM c"
            })
            .fetchAll();

        return results.resources; 
        },
        async ListById(_, {listId}: {listId:String}) {
            let results = await client
                .database("ToDoList")
                .container("Lists")
                .items.query({
                    query: "SELECT * FROM c WHERE c.id=@listId",
                    parameters: [
                        {
                            name: "@listId",
                            value: listId
                        }
                    ]
                })
                .fetchAll();

            return results.resources[0];
        },
        async ListItems(_, {listId}: {listId:String}) {
            let results = await client
                .database("ToDoList")
                .container("Items")
                .items.query({
                    query: "SELECT * FROM c WHERE c.listId=@listId",
                    parameters: [
                        {
                            name: "@listId",
                            value: listId
                        }
                    ]
                })
                .fetchAll();

            return results.resources;
        },
        async ListItemById(_, {listItemId}: {listItemId:String}) {
            let results = await client
                .database("ToDoList")
                .container("Items")
                .items.query({
                    query: "SELECT * FROM c WHERE c.id=@listItemId",
                    parameters: [
                        {
                            name: "@listItemId",
                            value: listItemId
                        }
                    ]
                })
                .fetchAll();

            return results.resources[0];
        }
    }
};

export default resolvers;