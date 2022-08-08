<template>
   <div class="todoCanvasRoot">
      <h3>Your to-do items for today</h3>
      <div class="loadingIcon" v-show="loading">
         <img src="images/loading.gif" />
      </div>
      <div class="todolistFlexContainer" v-show="todolists.length > 0">
         <div v-for="list of todolists" :key="list.id" class="todolist">
            <h3>{{ list.title }}</h3>
            <ul>
               <li v-for="listitem of list.items" :key="listitem.id">
                  {{ listitem.title }}
               </li>
            </ul>
         </div>
      </div>
   </div>
</template>

<script>
import { useMutation, useQuery, useResult } from "@vue/apollo-composable"
import { GET_LISTS } from "../graphql/queries"

export default {
  data: function() {
      return {
         todolists: [],
         loading: true
      }
   },
   created() {
      this.loading = true;

      try {
        //const listQuery = useQuery(GET_LISTS, {})
        const { result, loading, error } = useQuery(GET_LISTS, {})
        this.todolists = useResult(result, [], (data) => data?.Lists)
        this.loading = loading
      }
      catch (e) {
         console.log("error fetching data: "+e.message)
         //EventBus.$emit(Constants.EVENT_ERROR, "There was a problem fetching items. " + e.message);
      }
   },
   methods: {
   }
}
</script>
