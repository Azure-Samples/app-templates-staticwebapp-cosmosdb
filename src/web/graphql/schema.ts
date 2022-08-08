import { gql } from "apollo-server-azure-functions";

const typeDefs = gql`
    type ListItem {
        id: ID,
        list: List!
        title: String,
        status: String
    }

    type List {
        id: ID,
        title: String
        items: [ListItem]
    }

    type Query {
        Lists: [List]
        ListById(listId: String!): List
        ListItems(listId: String!): [ListItem]
        ListItemById(listItemId: String!): ListItem
    }
`;

export default typeDefs;