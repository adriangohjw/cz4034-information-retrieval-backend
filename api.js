// var express = require('express'),
//   app = express(),
//   port = process.env.PORT || 3001;

// app.listen(port);

// console.log('todo list RESTful API server started on: ' + port);

const { Client } = require('@elastic/elasticsearch')
const client = new Client({ node: 'http://localhost:9200'}) //, requestTimeout: 60000s

const querystring = require('querystring');
const express = require('express')
const app = express()
const port = 3001

// app.use(bodyParser.urlencoded({ extended: false }));
// app.use(bodyParser.json());

// /search?search_term=randomstuff&hashtags[]=hashtag1&hashtags[]=hashtag2




function elasticSearch(search_term, hashtag = [], query_from = 0, query_size = 20){



  

    var querySearch = {
        // bool: {
        //     must: SearchHelper.concat_hash_into_array(
        //       SearchHelper.querystring_to_hash(search_term)
        //     ) + SearchHelper::ArrayParam.new('hashtags', hashtags).value,
        //     filter: [],
        //     should: [],
        //     must_not: []
        // },
        "fuzzy": {
            "body": {
                "value": search_term,
                "fuzziness": "AUTO",
                "max_expansions": 50,
                "prefix_length": 0,
                "transpositions": true,
                "rewrite": "constant_score"
            }
        }
    };
    
    if(hashtag.length > 0){
      querySearch = {
        bool:{
          should: querySearch,
          must: {
            "terms": {
              "hashtags": hashtag,
              "boost": 1
            }
          }
        }
      }
    }

     return client.search({
        index: 'parler_posts',
        body: {
            from: query_from,
            size: query_size,
            query: {
              function_score:{
                query: querySearch,
                field_value_factor: {
                  field: "impressions",
                  factor: 1.2,
                  modifier: "square",
                  missing: 1
                }
              }
            }
        }
      }
      // , (err, result) => {
      //   if (err){ 
      //     console.log(err)
      //     return [];
      //   }else{
      //     console.log(result)
      //     return result.body.hits.hits;
      //   }
      // }
      )
}



app.get('/search', (req, res) => {
    let from = req.query.from;  
    let size = req.query.size;  

    let search_term = req.query.search_term;

    if(typeof search_term != 'string'){
      res.end("Invalid");
      return;
    }

    let hashtags = req.query.hashtags;
    if(typeof hashtags == 'string'){
      hashtags = hashtags.replace(/[`~!@#$%^&*()_|+\-=?;:'".<>\{\}\[\]\\\/]/gi,"")
      hashtags = hashtags.split(",");
    }
    // console.log(
      
      elasticSearch(search_term, hashtags, from, size)
      .then((result, err) => {
          if (err){ 
            console.log(err)
            res.end(JSON.stringify({posts:[]}));
          }else{
            res.end(JSON.stringify({posts:result.body.hits.hits}));
          }
          // console.log(err)
          // console.log(result)
        }).catch((err)=>
          {
            console.log(err);

          })
})



app.get('/suggest', (req, res) => {
  let from = req.query.from;  
  let size = req.query.size;  
  let search_term = req.query.search_term;

  if(typeof search_term != 'string'){
    res.end("Invalid");
    return;
  }

  let hashtags = req.query.hashtags;
  if(typeof hashtags == 'string'){
    hashtags = hashtags.replace(/[`~!@#$%^&*()_|+\-=?;:'".<>\{\}\[\]\\\/]/gi,"")
    hashtags = hashtags.split(",");
  }
  // console.log(
    
    elasticSuggest(search_term, hashtags, from, size)
    .then((result, err) => {
        if (err){ 
          console.log(err)
          res.end(JSON.stringify({posts:[]}));
        }else{
          if(result.body.suggest['suggest-term'].length < 1){
            res.end(JSON.stringify({posts:[]}));
          }
          res.end(JSON.stringify({posts:result.body.suggest['suggest-term'][0].options}));
        }
        // console.log(err)
        // console.log(result)
      }).catch((err)=>
        {
          console.log(err);

        })
})

function elasticSuggest(search_term, hashtag = [], query_from = 0, query_size = 20){

  return client.search({
     index: 'parler_posts',
     body: {
         // from: query_from,
         // size: query_size,
         "suggest": {
           "text" : search_term,
           "suggest-term" : {
             "term" : {
               "field" : "body",
               "size": 3,
               "sort": "frequency",
               "suggest_mode": "always"
             }
           },
           // "my-suggest-2" : {
           //   "text" : "kmichy",
           //   "term" : {
           //     "field" : "user.id"
           //   }
           // }
         }
     }
   }
  //  , (err, result) => {
  //    if (err){ 
  //      console.log(err)
  //      return [];
  //    }else{
  //      console.log(result.body.suggest['suggest-term'])
  //      return result.body.suggest['suggest-term'][0].options;
  //    }
  //  }
   )
 
 }

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
