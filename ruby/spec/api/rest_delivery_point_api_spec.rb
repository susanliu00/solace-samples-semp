=begin
#SEMP (Solace Element Management Protocol)

# SEMP (starting in `v2`, see [note 1](#notes)) is a RESTful API for configuring a Solace router.  SEMP uses URIs to address manageable **resources** of the Solace router. Resources are either individual **objects**, or **collections** of objects. The following APIs are provided:   API|Base Path|Purpose|Comments :---|:---|:---|:--- Configuration|/SEMP/v2/config|Reading and writing config state|See [note 2](#notes)    Resources are always nouns, with individual objects being singular and collections being plural. Objects within a collection are identified by an `obj-id`, which follows the collection name with the form `collection-name/obj-id`. Some examples:  <pre> /SEMP/v2/config/msgVpns                       ; MsgVpn collection /SEMP/v2/config/msgVpns/finance               ; MsgVpn object named \"finance\" /SEMP/v2/config/msgVpns/finance/queues        ; Queue collection within MsgVpn \"finance\" /SEMP/v2/config/msgVpns/finance/queues/orderQ ; Queue object named \"orderQ\" within MsgVpn \"finance\" </pre>  ## Collection Resources  Collections are unordered lists of objects (unless described as otherwise), and are described by JSON arrays. Each item in the array represents an object in the same manner as the individual object would normally be represented. The creation of a new object is done through its collection resource.  ## Object Resources  Objects are composed of attributes and collections, and are described by JSON content as name/value pairs. The collections of an object are not contained directly in the object's JSON content, rather the content includes a URI attribute which points to the collection. This contained collection resource must be managed as a separate resource through this URI.  At a minimum, every object has 1 or more identifying attributes, and its own `uri` attribute which contains the URI to itself. Attributes may have any (non-exclusively) of the following properties:   Property|Meaning|Comments :---|:---|:--- Identifying|Attribute is involved in unique identification of the object, and appears in its URI| Required|Attribute must be provided in the request| Read-Only|Attribute can only be read, not written|See [note 3](#notes) Write-Only|Attribute can only be written, not read| Requires-Disable|Attribute can only be changed when object is disabled| Deprecated|Attribute is deprecated, and will disappear in the next SEMP version|    In some requests, certain attributes may only be provided in certain combinations with other attributes:   Relationship|Meaning :---|:--- Requires|Attribute may only be changed by a request if a particular attribute or combination of attributes is also provided in the request Conflicts|Attribute may only be provided in a request if a particular attribute or combination of attributes is not also provided in the request    ## HTTP Methods  The HTTP methods of POST, PUT, PATCH, DELETE, and GET manipulate resources following these general principles:   Method|Resource|Meaning|Request Body|Response Body|Missing Request Attributes :---|:---|:---|:---|:---|:--- POST|Collection|Create object|Initial attribute values|Object attributes and metadata|Set to default PUT|Object|Replace object|New attribute values|Object attributes and metadata|Set to default (but see [note 4](#notes)) PATCH|Object|Update object|New attribute values|Object attributes and metadata | Left unchanged| DELETE|Object|Delete object|Empty|Object metadata|N/A GET|Object|Get object|Empty|Object attributes and metadata|N/A GET|Collection|Get collection|Empty|Object attributes and collection metadata|N/A    ## Common Query Parameters  The following are some common query parameters that are supported by many method/URI combinations. Individual URIs may document additional parameters. Note that multiple query parameters can be used together in a single URI, separated by the ampersand character. For example:  <pre> ; Request for the MsgVpns collection using two hypothetical query parameters ; \"q1\" and \"q2\" with values \"val1\" and \"val2\" respectively /SEMP/v2/config/msgVpns?q1=val1&q2=val2 </pre>  ### select  Include in the response only selected attributes of the object. Use this query parameter to limit the size of the returned data for each returned object, or return only those fields that are desired.  The value of `select` is a comma-separated list of attribute names. Names may include the `*` wildcard. Nested attribute names are supported using periods (e.g. `parentName.childName`). If the list is empty (i.e. `select=`) no attributes are returned; otherwise the list must match at least one attribute name of the object. Some examples:  <pre> ; List of all MsgVpn names /SEMP/v2/config/msgVpns?select=msgVpnName  ; Authentication attributes of MsgVpn \"finance\" /SEMP/v2/config/msgVpns/finance?select=authentication*  ; Access related attributes of Queue \"orderQ\" of MsgVpn \"finance\" /SEMP/v2/config/msgVpns/finance/queues/orderQ?select=owner,permission </pre>  ### where  Include in the response only objects where certain conditions are true. Use this query parameter to limit which objects are returned to those whose attribute values meet the given conditions.  The value of `where` is a comma-separated list of expressions. All expressions must be true for the object to be included in the response. Each expression takes the form:  <pre> expression  = attribute-name OP value OP          = '==' | '!=' | '<' | '>' | '<=' | '>=' </pre>  `value` may be a number, string, `true`, or `false`, as appropriate for the type of `attribute-name`. Greater-than and less-than comparisons only work for numbers. A `*` in a string `value` is interpreted as a wildcard. Some examples:  <pre> ; Only enabled MsgVpns /SEMP/v2/config/msgVpns?where=enabled==true  ; Only MsgVpns using basic non-LDAP authentication /SEMP/v2/config/msgVpns?where=authenticationBasicEnabled==true,authenticationBasicType!=ldap  ; Only MsgVpns that allow more than 100 client connections /SEMP/v2/config/msgVpns?where=maxConnectionCount>100 </pre>  ### count  Limit the count of objects in the response. This can be useful to limit the size of the response for large collections. The minimum value for `count` is `1` and the default is `10`. There is a hidden maximum as to prevent overloading the system. For example:  <pre> ; Up to 25 MsgVpns /SEMP/v2/config/msgVpns?count=25 </pre>  ### cursor  The cursor, or position, for the next page of objects. Cursors are opaque data that should not be created or interpreted by SEMP clients, and should only be used as described below.  When a request is made for a collection and there may be additional objects available for retrieval that are not included in the initial response, the response will include a `cursorQuery` field containing a cursor. The value of this field can be specified in the `cursor` query parameter of a subsequent request to retrieve the next page of objects. For convenience, an appropriate URI is constructed automatically by the router and included in the `nextPageUri` field of the response. This URI can be used directly to retrieve the next page of objects.  ## Notes  1. This specification defines SEMP starting in `v2`, and not the original SEMP `v1` interface. Request and response formats between `v1` and `v2` are entirely incompatible, although both protocols share a common port configuration on the Solace router. They are differentiated by the initial portion of the URI path, one of either `/SEMP/` or `/SEMP/v2/`. 2. The config API is partially implemented. Only a subset of all configurable objects are available. 3. Read-only attributes may appear in POST and PUT/PATCH requests. However, if a read-only attribute is not marked as identifying, it will be ignored during a PUT/PATCH. 4. For PUT, if the SEMP user is not authorized to modify the attribute, its value is left unchanged rather than set to default. In addition, the values of write-only attributes are not set to their defaults on a PUT. 5. For DELETE, the body of the request currently serves no purpose and will cause an error if not empty. 

OpenAPI spec version: 2.8.0.0.18
Contact: support_request@solacesystems.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end

require 'spec_helper'
require 'json'

# Unit tests for SempClient::RestDeliveryPointApi
# Automatically generated by swagger-codegen (github.com/swagger-api/swagger-codegen)
# Please update as you see appropriate
describe 'RestDeliveryPointApi' do
  before do
    # run before each test
    @instance = SempClient::RestDeliveryPointApi.new
  end

  after do
    # run after each test
  end

  describe 'test an instance of RestDeliveryPointApi' do
    it 'should create an instact of RestDeliveryPointApi' do
      expect(@instance).to be_instance_of(SempClient::RestDeliveryPointApi)
    end
  end

  # unit tests for create_msg_vpn_rest_delivery_point
  # Creates a REST Delivery Point object.
  # Creates a REST Delivery Point object. Any attribute missing from the request will be set to its default value.   Attribute|Identifying|Required|Read-Only|Write-Only|Deprecated :---|:---:|:---:|:---:|:---:|:---: msgVpnName|x||x|| restDeliveryPointName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param body The REST Delivery Point object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointResponse]
  describe 'create_msg_vpn_rest_delivery_point test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for create_msg_vpn_rest_delivery_point_queue_binding
  # Creates a Queue Binding object.
  # Creates a Queue Binding object. Any attribute missing from the request will be set to its default value.   Attribute|Identifying|Required|Read-Only|Write-Only|Deprecated :---|:---:|:---:|:---:|:---:|:---: msgVpnName|x||x|| queueBindingName|x|x||| restDeliveryPointName|x||x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param body The Queue Binding object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointQueueBindingResponse]
  describe 'create_msg_vpn_rest_delivery_point_queue_binding test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for create_msg_vpn_rest_delivery_point_rest_consumer
  # Creates a REST Consumer object.
  # Creates a REST Consumer object. Any attribute missing from the request will be set to its default value.   Attribute|Identifying|Required|Read-Only|Write-Only|Deprecated :---|:---:|:---:|:---:|:---:|:---: authenticationHttpBasicPassword||||x| msgVpnName|x||x|| restConsumerName|x|x||| restDeliveryPointName|x||x||    The following attributes in the request may only be provided in certain combinations with other attributes:   Class|Attribute|Requires|Conflicts :---|:---|:---|:--- MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicPassword|authenticationHttpBasicUsername| MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicUsername|authenticationHttpBasicPassword| MsgVpnRestDeliveryPointRestConsumer|remotePort|tlsEnabled| MsgVpnRestDeliveryPointRestConsumer|tlsEnabled|remotePort|    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param body The REST Consumer object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerResponse]
  describe 'create_msg_vpn_rest_delivery_point_rest_consumer test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for create_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name
  # Creates a Trusted Common Name object.
  # Creates a Trusted Common Name object. Any attribute missing from the request will be set to its default value.   Attribute|Identifying|Required|Read-Only|Write-Only|Deprecated :---|:---:|:---:|:---:|:---:|:---: msgVpnName|x||x|| restConsumerName|x||x|| restDeliveryPointName|x||x|| tlsTrustedCommonName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param body The Trusted Common Name object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerTlsTrustedCommonNameResponse]
  describe 'create_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for delete_msg_vpn_rest_delivery_point
  # Deletes a REST Delivery Point object.
  # Deletes a REST Delivery Point object.  A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param [Hash] opts the optional parameters
  # @return [SempMetaOnlyResponse]
  describe 'delete_msg_vpn_rest_delivery_point test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for delete_msg_vpn_rest_delivery_point_queue_binding
  # Deletes a Queue Binding object.
  # Deletes a Queue Binding object.  A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param queue_binding_name The queueBindingName of the Queue Binding.
  # @param [Hash] opts the optional parameters
  # @return [SempMetaOnlyResponse]
  describe 'delete_msg_vpn_rest_delivery_point_queue_binding test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for delete_msg_vpn_rest_delivery_point_rest_consumer
  # Deletes a REST Consumer object.
  # Deletes a REST Consumer object.  A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param [Hash] opts the optional parameters
  # @return [SempMetaOnlyResponse]
  describe 'delete_msg_vpn_rest_delivery_point_rest_consumer test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for delete_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name
  # Deletes a Trusted Common Name object.
  # Deletes a Trusted Common Name object.  A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param tls_trusted_common_name The tlsTrustedCommonName of the Trusted Common Name.
  # @param [Hash] opts the optional parameters
  # @return [SempMetaOnlyResponse]
  describe 'delete_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point
  # Gets a REST Delivery Point object.
  # Gets a REST Delivery Point object.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointResponse]
  describe 'get_msg_vpn_rest_delivery_point test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_queue_binding
  # Gets a Queue Binding object.
  # Gets a Queue Binding object.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| queueBindingName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param queue_binding_name The queueBindingName of the Queue Binding.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointQueueBindingResponse]
  describe 'get_msg_vpn_rest_delivery_point_queue_binding test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_queue_bindings
  # Gets a list of Queue Binding objects.
  # Gets a list of Queue Binding objects.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| queueBindingName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param [Hash] opts the optional parameters
  # @option opts [Integer] :count Limit the count of objects in the response. See [Count](#count \&quot;Description of the syntax of the &#x60;count&#x60; parameter\&quot;).
  # @option opts [String] :cursor The cursor, or position, for the next page of objects. See [Cursor](#cursor \&quot;Description of the syntax of the &#x60;cursor&#x60; parameter\&quot;).
  # @option opts [Array<String>] :where Include in the response only objects where certain conditions are true. See [Where](#where \&quot;Description of the syntax of the &#x60;where&#x60; parameter\&quot;).
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointQueueBindingsResponse]
  describe 'get_msg_vpn_rest_delivery_point_queue_bindings test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_rest_consumer
  # Gets a REST Consumer object.
  # Gets a REST Consumer object.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: authenticationHttpBasicPassword||x| msgVpnName|x|| restConsumerName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerResponse]
  describe 'get_msg_vpn_rest_delivery_point_rest_consumer test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name
  # Gets a Trusted Common Name object.
  # Gets a Trusted Common Name object.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| restConsumerName|x|| restDeliveryPointName|x|| tlsTrustedCommonName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param tls_trusted_common_name The tlsTrustedCommonName of the Trusted Common Name.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerTlsTrustedCommonNameResponse]
  describe 'get_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_name test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_names
  # Gets a list of Trusted Common Name objects.
  # Gets a list of Trusted Common Name objects.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| restConsumerName|x|| restDeliveryPointName|x|| tlsTrustedCommonName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :where Include in the response only objects where certain conditions are true. See [Where](#where \&quot;Description of the syntax of the &#x60;where&#x60; parameter\&quot;).
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerTlsTrustedCommonNamesResponse]
  describe 'get_msg_vpn_rest_delivery_point_rest_consumer_tls_trusted_common_names test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_point_rest_consumers
  # Gets a list of REST Consumer objects.
  # Gets a list of REST Consumer objects.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: authenticationHttpBasicPassword||x| msgVpnName|x|| restConsumerName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param [Hash] opts the optional parameters
  # @option opts [Integer] :count Limit the count of objects in the response. See [Count](#count \&quot;Description of the syntax of the &#x60;count&#x60; parameter\&quot;).
  # @option opts [String] :cursor The cursor, or position, for the next page of objects. See [Cursor](#cursor \&quot;Description of the syntax of the &#x60;cursor&#x60; parameter\&quot;).
  # @option opts [Array<String>] :where Include in the response only objects where certain conditions are true. See [Where](#where \&quot;Description of the syntax of the &#x60;where&#x60; parameter\&quot;).
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumersResponse]
  describe 'get_msg_vpn_rest_delivery_point_rest_consumers test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for get_msg_vpn_rest_delivery_points
  # Gets a list of REST Delivery Point objects.
  # Gets a list of REST Delivery Point objects.   Attribute|Identifying|Write-Only|Deprecated :---|:---:|:---:|:---: msgVpnName|x|| restDeliveryPointName|x||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readonly\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param [Hash] opts the optional parameters
  # @option opts [Integer] :count Limit the count of objects in the response. See [Count](#count \&quot;Description of the syntax of the &#x60;count&#x60; parameter\&quot;).
  # @option opts [String] :cursor The cursor, or position, for the next page of objects. See [Cursor](#cursor \&quot;Description of the syntax of the &#x60;cursor&#x60; parameter\&quot;).
  # @option opts [Array<String>] :where Include in the response only objects where certain conditions are true. See [Where](#where \&quot;Description of the syntax of the &#x60;where&#x60; parameter\&quot;).
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointsResponse]
  describe 'get_msg_vpn_rest_delivery_points test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for replace_msg_vpn_rest_delivery_point
  # Replaces a REST Delivery Point object.
  # Replaces a REST Delivery Point object. Any attribute missing from the request will be set to its default value, unless the user is not authorized to change its value in which case the missing attribute will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: clientProfileName||||x| msgVpnName|x|x||| restDeliveryPointName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param body The REST Delivery Point object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointResponse]
  describe 'replace_msg_vpn_rest_delivery_point test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for replace_msg_vpn_rest_delivery_point_queue_binding
  # Replaces a Queue Binding object.
  # Replaces a Queue Binding object. Any attribute missing from the request will be set to its default value, unless the user is not authorized to change its value in which case the missing attribute will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: msgVpnName|x|x||| queueBindingName|x|x||| restDeliveryPointName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param queue_binding_name The queueBindingName of the Queue Binding.
  # @param body The Queue Binding object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointQueueBindingResponse]
  describe 'replace_msg_vpn_rest_delivery_point_queue_binding test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for replace_msg_vpn_rest_delivery_point_rest_consumer
  # Replaces a REST Consumer object.
  # Replaces a REST Consumer object. Any attribute missing from the request will be set to its default value, unless the user is not authorized to change its value in which case the missing attribute will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: authenticationHttpBasicPassword|||x|x| authenticationHttpBasicUsername||||x| authenticationScheme||||x| msgVpnName|x|x||| outgoingConnectionCount||||x| remoteHost||||x| remotePort||||x| restConsumerName|x|x||| restDeliveryPointName|x|x||| tlsCipherSuiteList||||x| tlsEnabled||||x|    The following attributes in the request may only be provided in certain combinations with other attributes:   Class|Attribute|Requires|Conflicts :---|:---|:---|:--- MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicPassword|authenticationHttpBasicUsername| MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicUsername|authenticationHttpBasicPassword| MsgVpnRestDeliveryPointRestConsumer|remotePort|tlsEnabled| MsgVpnRestDeliveryPointRestConsumer|tlsEnabled|remotePort|    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param body The REST Consumer object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerResponse]
  describe 'replace_msg_vpn_rest_delivery_point_rest_consumer test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for update_msg_vpn_rest_delivery_point
  # Updates a REST Delivery Point object.
  # Updates a REST Delivery Point object. Any attribute missing from the request will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: clientProfileName||||x| msgVpnName|x|x||| restDeliveryPointName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param body The REST Delivery Point object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointResponse]
  describe 'update_msg_vpn_rest_delivery_point test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for update_msg_vpn_rest_delivery_point_queue_binding
  # Updates a Queue Binding object.
  # Updates a Queue Binding object. Any attribute missing from the request will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: msgVpnName|x|x||| queueBindingName|x|x||| restDeliveryPointName|x|x|||    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param queue_binding_name The queueBindingName of the Queue Binding.
  # @param body The Queue Binding object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointQueueBindingResponse]
  describe 'update_msg_vpn_rest_delivery_point_queue_binding test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

  # unit tests for update_msg_vpn_rest_delivery_point_rest_consumer
  # Updates a REST Consumer object.
  # Updates a REST Consumer object. Any attribute missing from the request will be left unchanged.   Attribute|Identifying|Read-Only|Write-Only|Requires-Disable|Deprecated :---|:---:|:---:|:---:|:---:|:---: authenticationHttpBasicPassword|||x|x| authenticationHttpBasicUsername||||x| authenticationScheme||||x| msgVpnName|x|x||| outgoingConnectionCount||||x| remoteHost||||x| remotePort||||x| restConsumerName|x|x||| restDeliveryPointName|x|x||| tlsCipherSuiteList||||x| tlsEnabled||||x|    The following attributes in the request may only be provided in certain combinations with other attributes:   Class|Attribute|Requires|Conflicts :---|:---|:---|:--- MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicPassword|authenticationHttpBasicUsername| MsgVpnRestDeliveryPointRestConsumer|authenticationHttpBasicUsername|authenticationHttpBasicPassword| MsgVpnRestDeliveryPointRestConsumer|remotePort|tlsEnabled| MsgVpnRestDeliveryPointRestConsumer|tlsEnabled|remotePort|    A SEMP client authorized with a minimum access scope/level of \&quot;vpn/readwrite\&quot; is required to perform this operation.
  # @param msg_vpn_name The msgVpnName of the Message VPN.
  # @param rest_delivery_point_name The restDeliveryPointName of the REST Delivery Point.
  # @param rest_consumer_name The restConsumerName of the REST Consumer.
  # @param body The REST Consumer object&#39;s attributes.
  # @param [Hash] opts the optional parameters
  # @option opts [Array<String>] :select Include in the response only selected attributes of the object. See [Select](#select \&quot;Description of the syntax of the &#x60;select&#x60; parameter\&quot;).
  # @return [MsgVpnRestDeliveryPointRestConsumerResponse]
  describe 'update_msg_vpn_rest_delivery_point_rest_consumer test' do
    it "should work" do
      # assertion here. ref: https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
    end
  end

end
