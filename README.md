## sensu event handler for Elasticsearch

#### about

 * seusn event data post to Elasticserach index.

#### how to use

 1. `cd /path/to/sensu/handlers`
 1. `wget https://raw.githubusercontent.com/inokappa/sensu-handler-elasticserch/master/elasticsearch.rb` 
 1. `chmod 755 elasticsearch.rb`
 1. `cd /path/to/sensu/conf.d/`
 1. `wget https://raw.githubusercontent.com/inokappa/sensu-handler-elasticserch/master/elasticsearch.json`
 1. Please modify to suit your Elasticsearch environment this file(elasticsearch.json).
 1. Please restart sensu-server.