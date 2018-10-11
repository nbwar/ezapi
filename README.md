# EZApi

EZApi makes interfacing with third party APIs easy! EZApi handles network requests, responses, and serializes the object into an easy to use ruby object. Standard RESTful actions are included out of the box  and you can easily add custom actions.

## Usage

Install the gem
```ruby
gem 'ezapi'
```

Define your API client & models
```ruby
module ThirdPartyApp
  extend EZApi::Client

  api_url 'http://www.example.com/api/' # => / at the end is required
  api_key 'XXXXXX' # => required


  class User < EZApi::ObjectBase
    path 'foo' # => to create custom path. Defaults to 'users' in this case
    actions [:show, :create, :delete, :update, :index] # => Included RESTful actions
  end
end
```

Now we can call `http://www.example.com/api/users` endpoints
```ruby
begin
  user = ThirdPartyApp::User.show('123')
  user.first_name # => returns first_name json field
  user.first_name = 'new name'
  user.save

  ThirdPartyApp::User.delete('123')
  ThirdPartyApp::User.update({first_name: 'Name'})
  ThirdPartyApp::User.index({page: 1})
rescue EZApiError => e
  print(e.message)
end
```


### Custom actions

There are two ways of adding custom actions that are not in the included rest
```ruby
module ThirdPartyApp
  class User < EZApi::ObjectBase
    # For class methods
    def self.custom_action
      response = client.get("#{api_path}/custom_action")
      # Do whatever you want with the response
    end

    # for instance methods
    def custom_instance_action
      response = self.class.client.get("#{self.class.api_path}/custom_action")
      # Do whatever you want with the response
    end
  end
end


ThirdPartyApp::User.custom_action
ThirdPartyApp::User.new.custom_instance_action
```


#### Add custom actions to actions array
```ruby
module ThirdPartyApp
  module Actions
    module MyCustomAction
      def my_custom_action
        # Do Something
      end
    end
  end
end

module ThirdPartyApp
  class User < EZApi::ObjectBase
    actions [:my_custom_action]
  end
end

```
You can even override the include REST actions using this method
