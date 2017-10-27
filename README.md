[![Build Status](https://travis-ci.org/sapcc/elektra.svg?branch=master)](https://travis-ci.org/sapcc/elektra)

Elektra
=================

![Elektra Landing Page](https://github.com/sapcc/documents/raw/master/screenshots/sapcc_elektra_landing_page.png)

Elektra is an opinionated Openstack Dashboard for Operators and Consumers of Openstack Services. Its goal is to make Openstack more accessible to end-users.

To that end Elektra provides web UIs that turn operator actions into user self-services.

**User self-services:**
* User onboarding
* Project creation and configuration
* Quota requests
* Authorizations and access control for projects and services
* Cost control

**We have UIs for the following Openstack core services**:
* Compute: servers, server images, server snapshots (Nova)
* Block storage: volumes, volume snapshots (Cinder)
* User and group roles assignemnts (Keystone)
* Secure key store (Barbican)
* Software-defined networks, routers, floating IPs, security groups (Neutron)
* Loadbalancing (Neutron LBaaS extension)
* DNS (Designate)
* Object storage (Swift)
* Shared file storage (Manila)

**Extended services:**

* SAP Automation as a Service
* SAP Hana as a Service
* SAP Kubernetes as a Service (2017)


**Project Landing Page:**

![Elektra Project Screen](https://github.com/sapcc/documents/raw/master/screenshots/sapcc_elektra_project_screen.png)

Where does the name come from?
------------------------------
In Greek mythology Elektra, the bright or brilliant one, is the Goddess of Clouds with a silver lining.


Installing and Running Elektra
==============================


Prerequisites
-------------
1. DevStack or Openstack installation, Mitaka Release

   a. **Important:** Ensure Keystone V3 is activated. By default DevStack uses V2 (which has no domain support). Adding ```IDENTITY_API_VERSION=3``` to local.conf enables V3 support in DevStack

   b. **Important:** Ensure the service user you configured in your **.env** file (see below) has the admin role in the Default domain and all other domains you want to use.
2. installed postgres database
3. ruby installation, version >= 2.2.0, bundler installation  


Application Installation with bundler
-------------------------------------
1. run: ```bundle install```
2. copy the **env.sample** file to a **.env** file and adjust the values
    - Set the MONSOON_OPENSTACK_AUTH_API_* values to your devstack/openstack configuration settings
    - Enter the database configuration parameters
2. run: ```rake db:create```
3. run: ```rake db:seed```


Start the Elektra Dashboard Application
---------------------------------------
1. run: ```foreman start```. **Important:** Ensure the **PORT** parameter is set in **.env**! This will start the rails server and also the webpack-dev-server.
2. Browser access for Elektra: http://localhost:5000/Default
3. DevStack: Login with user demo/devstack


Use Elektra Request Management
------------------------------
1. Create another administrator user for the Default domain with email address in Horizon or with CLI
2. Configure MONSOON_DASHBOARD_MAIL_SERVER accordingly
3. Restart Elektra Application


Available Services in Elektra
-----------------------------
If elektra is configured against a standard DevStack installation, only the core services like identity, nova, neutron and cinder are (sometimes partly) available and
shown in Elektra. Additional services like swift, LBaaS, manila, ... will only be shown when available from the DevStack backend side.  


Running the cucumber tests
--------------------------

The following ENV parameters can be set for running cucumbers:

CCTEST_DOMAIN= ```[test domain name,default:cctest_cluster_3]```

CCTEST_PROJECT= ```[test project name, default:public]```

CCTEST_USER= ```[test user name, default:cctest_cluster_3_member]```

CCTEST_PASSWORD= ```[test user password]```

Profiles e2e and admin are relevant:

* **e2e:** Should pass with project member user
* **admin:** Should only pass with an domain admin user


The ENV parameters can also be passed in command line like:

```bin/cucumber CCTEST_PROJECT=admin CCTEST_USER=cctest_cluster_3_admin CCTEST_PASSWORD=XXX -p admin```


Create a new Plugin
-------------------

For more information about plugins, see the chapter "What are Plugins?" below.

The complexity of a plugin may vary greatly depending on its purpose. For example a Lib Plugin includes no app tree and is not mountable. However, it contains a lib folder and therefore implements libraries which may be used in other plugins. The next complexity level is the ServiceLayer Plugin, which already contains a partial app tree but isn't mountable and doesn't define views, it offers a service or library which may be used in other plugins (the ``Core::ServiceLayer`` is an example of such a plugin). The last plugin type is the mountable plugin which includes a full app tree and its own routes and views and is able to be mounted and act as an isolated rails app (The network plugin is an example of a mountable plugin).

* Lib Plugin
  * includes a "lib" directory and no app tree
* ServiceLayer Plugin
  * includes an implementation of ServiceLayer and DomainModel
  * app tree partially available
  * is a Rails Engine
* Mountable Plugin
  * includes a full app tree
  * can be mounted and define own routes
  * is a Rails Engine

For ease-of-use we have provided a generator which generates a skeleton plugin folder structure with the necessary elements and some basic classes with the proper inheritance to get started. First decide which type of plugin you want to start developing (for more infos about plugins see "What are Plugins?" below):

#### Create Lib Plugin
``` cd [Elektra root]```

```bin/rails g dashboard_plugin NAME```

#### Create ServiceLayer Plugin
``` cd [Elektra root]```

```bin/rails g dashboard_plugin NAME --service_layer```

#### Create Mountable Plugin
``` cd [Elektra root]```

```bin/rails g dashboard_plugin NAME --mountable```

#### Create Mountable ServiceLayer-Plugin
``` cd [Elektra root]```

```bin/rails g dashboard_plugin NAME --mountable --service_layer```

### Creating Migrations

If your plugin needs to save things in the Elektra database, you'll need to create a migration. Migrations and the models they belong to live within the plugin. One additional step is necessary to register your migration with the host app so that it is applied when ``rake db:migrate`` is called in the host app. To create a new migration in your plugin do the following:

**Background:** you have a plugin named ``my_plugin``.

1. ``cd [Elektra root]/plugins/my_plugin``

    Inside this (mountable) plugin you will find a bin folder and rails script within this folder.

2. ```bin/rails g migration entries```

    A new migration was generated under ```plugins/my_plugin/db/migrations/```

3. Register this engine's migration for the global rake task

    ```ruby
    initializer 'my_plugin.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end
    ```

4. ```cd [Elektra root]```

    ```rake db:migrate```



Plugin Assets
--------------

The Elektra UI design is a theme for [Twitter Bootstrap (v3.~)](http://getbootstrap.com/). All components described in the Twitter Bootstrap documentation also work in Elektra. Additionally we have added some components of our own. We have included [Font Awesome](https://fortawesome.github.io/Font-Awesome/) for icons.

**Important:** When building views for your plugin please check existing plugins for established best practices and patterns and also check with the core team so that the user experience stays the same or similar across plugins.

In many cases the provided styles will be enough to build your views. If you need extra styles or scripts please coordinate with the core team to see whether we should include them in the core styles so they become accessible for everybody or whether they should remain specific to your plugin. **Assets that are specific to your plugin must be located in the assets folder in your plugin.**



What are Plugins?
-----------------

![Dashboard-Plugins](docs/Dashboard-Plugins.jpg?raw=true)

The concept of plugins aims to outsource parts of Elektra, thus enabling developers to work decoupled from the main app and from each other. Rather than putting everything in the "app" directory of the main app, the controllers, views and models are split into plugins. An Elektra plugin encapsulates functionality which belongs together conceptually and/or technically and which is to be integrated into Elektra for consumption by the end user. The network plugin for example contains all the necessary controllers and views as well as helper classes to create, edit and delete network objects.

The core app provides layout, user and token handling, manages the plugins and offers classes that can be extended by plugins to make use of the functionality they provide. For example, checking whether the user is registered or logged in and the logic for the rescoping is implemented in the ``DashboardController`` in the core app. Plugin controllers can inherit from this class and won't have to worry about user management themselves.

Furthermore, the core app provides a service layer through which plugins are able to access other plugins' service methods on the controller level.


### Service Layer

In principle an Elektra plugin is able to store data in the Elektra database and to access it via the ActiveRecord layer. However, many plugins communicate via an API with services which persist the necessary data themselves. Elektra plugins use the _Service Layer_ to communicate with these backend services. Services in this case are primarily OpenStack services like compute or identity. Though other custom services can also be accessed the same way by the plugin.

**Important:** The communication with such services requires a valid user token (OpenStack Keystone).

As described above, the ``DashboardController`` in the core app takes care of user authentication. Each plugin controller that inherits from this controller automatically includes a reference to ``current_user`` which represents the token. The plugin can now use the information in ``current_user`` (mainly the token) to interact with the backend services.

But how can a plugin, for example the compute plugin, access the network methods which are implemented in the network plugin? This is where the service layer comes into play. The ``DashboardController`` offers a method called ``services`` which contains the reference to all available plugin backend services. For example: ```services_ng.networking.networks``` invokes the method networks from the network backend service. Thus, the _Service Layer_ represents a communication channel to the main backend service a plugin consumes and also to the other plugin backend services.

**Before you consume other backend services:** Check how expensive a backend call is. If it is expensive take steps to reduce how often the call is made (e.g. by caching, displaying the information on a view that isn't accessed very often) or at least make the call asynchronously so as to not block the rest of the page from loading.

### Driver Layer and Domain Model

To avoid services having to communicate directly with the API and each plugin having to implement its own client, we introduced a driver layer. This layer is located exactly between the service and the API client. Thereby it is possible to abstract the services from the specific client implementation. The driver implements methods that send or receive data to or from the API and are invoked directly by a service. The data format between service and driver is limited to the Ruby Hash. Hashes are in principle sufficient for further processing, but in the UI data is usually collected via HTML forms and must be validated before it is sent on to the API. Furthermore you often require helper methods that are not implemented in the hashes.

The mentioned drawbacks of pure hash use are eliminated by the concept of the Domain Model. The Domain Model wraps the data hash and implements methods that work on this hash. By inheriting from the core Domain Model (``Core::ServiceLayer::Model``) your model gets CRUD operations out of the box. You can then add additional methods for formatting, processing, etc.

Services call driver methods and map the responses to Domain Model objects and, conversely, the Domain Model objects are converted to hashes when they reach the driver layer. As a result, it is possible to work with real ruby objects in plugins rather than using hashes. In such Domain Model objects we can use validations and define helper methods.

### Plugin Folder Structure

The following diagram illustrates how plugins are structured and which core classes to inherit to make it all work as described above.
![Plugins](docs/dashboard_plugins_tree.jpg?raw=true)

[Click here for a detailed class diagram](docs/dashboard_services.pdf)


Adding gem dependencies with native extensions
----------------------------------------------
The Elektra Docker image does not contain the build chain for compiling ruby extensions. Gems which contain native extensions need to be pre-built and packaged as alpine packages (apk).



Audit Log
---------
Each controller which inherits from ```DashboardController``` provides access to audit log via audit_logger. Internally this logger uses the Rails logger and thus the existing log infrastructure.

### How to use Audit Logger

```ruby
audit_logger.info(“user johndoe has deleted project 54353454353455435345")
# => [AUDIT LOG] user johndoe has deleted project 54353454353455435345
```

```ruby
audit_logger.info(current_user, "has deleted project", @project_id)  
# => [AUDIT LOG] CurrentUserWrapper johndoe (7ebe1bbd17b36c685389c29bd861d8c337d70a2f56022f80b71a5a13852e6f96) has deleted project JohnProject (adac5c36277b4346bbd631811af533f3)
```
```ruby
audit_logger.info(user: johndoe, has: “deleted”, project: "54353454353455435345")
# => [AUDIT LOG] user johndoe has deleted project 54353454353455435345
```
```ruby
audit_logger.info(“user johndoe”, “has deleted”, “project 54353454353455435345")
# => [AUDIT LOG] user johndoe has deleted project 54353454353455435345
```

### Available Methods
* audit_logger.info
* audit_logger.warn
* audit_logger.error
* audit_logger.debug
* audit_logger.fatal


Catch Errors in Controller
---------------

The Elektra ApplicationController provides a class method which allows the catching of errors and will render a well designed error page.

```ruby
rescue_and_render_exception_pagepage [
  { "Excon::Error" => { title: 'Backend Service Error', description: 'Api Error', details: -> e {e.backtrace.join("\n")}}},
  { "Fog::OpenStack::Errors::ServiceError" => { title: 'Backend Service Error' }},
  "Core::ServiceLayer::Errors::ApiError"
]
```  

Errors that are caught in this way, are rendered within the application layout so that the navigation remains visible. For example if a service is unavailable the user gets to see an error but she can still navigate to other services.

### How to urescue_and_render_exception_pagepage accepts an array of hashes and/or strings. In case you want to overwrite the rendered attributes you should provide a hash with a mapping.

Available attributes:
* ```title``` (error title)
* ```description``` (error message)
* ```details``` (some details like backtrace)
* ```exception_id``` (default is request uuid)
* ```warnign``` (default false. If true a warning page is rendered instead of error page)


Display Quota Data
------------------

If the variable ```@quota_data``` is set the view will display all data inside this variable.

### How to set @quota_data

This will load quota data from the database and update the usage attribute.
```ruby
@quota_data = services_ng.resource_management.quota_data(
  current_user.domain_id || current_user.project_domain_id,
  current_user.project_id,[
  {service_type: 'compute', resource_name: 'instances', usage: @instances.length},
  {service_type: 'compute', resource_name: 'cores', usage: cores},
  {service_type: 'compute', resource_name: 'ram', usage: ram}
])
```

Same example but without updating the usage attribute. It just loads the values from the database. Note that the database is not always up to date.

```ruby
@quota_data = services_ng.resource_management.quota_data(
  current_user.domain_id || current_user.project_domain_id,
  current_user.project_id,[
  {service_type: 'compute', resource_name: 'instances'},
  {service_type: 'compute', resource_name: 'cores'},
  {service_type: 'compute', resource_name: 'ram'}
])
```

Pagination
----------

### Controller

```ruby
@images = paginatable(per_page: 15) do |pagination_options|
  services.image.images({sort_key: 'name', visibility: @visibility}.merge(pagination_options))
end
```

### View

```ruby
= render_paginatable(@images)
```
