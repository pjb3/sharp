# Creating Your First App

Sharp comes with an application generator built in to help you get started.  To create a sharp app, simply run the following command:

    $ sharp new hello_world

You application will be created in the `hello_world` directory.  Next we'll take a look at what Sharp created for you.

# Layout of an Application

The directories and files created in the `hello_world` directory are as follows:

	├── app/
	│   ├── actions/
	│   │   ├── application_action.rb
	│   │   └── root_action.rb
	│   ├── initializers/
	│   │   ├── post/
	│   │   └── pre/
	│   ├── lib/
	│   ├── models/
	│   ├── views/
	│   │   └── application_view.rb
	│   ├── boot.rb
	│   └── routes.rb
	├── assets/
	│   ├── javascripts/
	│   ├── stylesheets/
	│   └── packages.yml
	├── config/
	├── public/
	│   ├── favicon.ico
	│   └── robots.txt
	├── templates/
	│   ├── layouts/
	│   │   └── application.erb
	│   └── root.erb
	├── vendor/
	│   └── assets/
	│       ├── javascripts/
	│       └── stylesheets/
	├── Gemfile
	├── Guardfile
	├── Rakefile
	└── config.ru
	
Throughout the rest of this tutorial, we'll cover in detail what each of these subdirectories and files are used for, but for now, we'll just go over the top-level directories.

## app

Contains the Ruby code specific to your application.  Some files have been created here to help get you started.

## assets

Contains the CSS and JS specific to your application.

## config

This directory contains configuration files for details that will change based upon the environment you are running your application in.

## public

Contains the static files that will be served be the web server.

## templates

Contains the templates used to generate HTML.  The default templating language is ERB, but Haml, Slim, Liquid, Mustache and other various templating languages can be used as well.

## vender

Contains 3rd party CSS and JS you are using in your application.  You typically don't modify these files, you import them from another project, such as [jQuery][jquery] or [Twitter Bootstrap][bootstrap].

# Starting the Server

Now that you have a Sharp application, you can start up the server and see your first web page!  Sharp uses [Bundler][bundler] by default, so to get rolling, make sure you have bundler installed and run bundler:

    $ bundle

To start the server, run this command from within the `hello_world` directory:

    $ shotgun

This will start the application on port 9393.  You can see what the homepage looks like by running this command:

    $ curl -s http://localhost:9393
    <!doctype html>
    <html>
      <head>
        <title>Hello, World!</title>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
    </html>

You can, of course, also look at this page in your browser:

    $ open http://localhost:9393

Next up, we'll dive into how this page is created.

# Routing

When your application receives a request, the first thing that happens is the router determines which action to use to generate the response.  The routes are defined in the file `app/routes.rb`, which looks like this:

``` ruby
Sharp.routes do
  get '/' => RootAction
end
```

What this means is if the request is a `GET` and the path is just `/`, call the `RootAction` to generate the response.  We'll go into routing in more detail later, but for now, let's take a look at what the `RootAction` does.

# Actions

So as we've seen, the router determines what action should respond to a request, and it is the job of an action to generate the response.  If we look at the `RootAction`, which is defined in `app/actions/root_action.rb`, we see this:

``` ruby
class RootAction < ApplicationAction
end
```

Huh, not much going on there, is there?  That's because the default behavior of an action is to render the template that matches the name of the action.  In this case, the action is `app/actions/root_action.rb`, so the template will be `templates/root.erb`.  We'll cover actions in more depth later, but let's take a look at the template next.

# Templates

There is what the template that is used to generate our response, `templates/root.erb`, looks like:

``` erb
<h1>Hello, World!</h1>
```

There's not much to it yet.  In fact, this is just a static snippet of HTML.  Templates typically have Ruby code mixed in with the HTML, in order to generate a dynamic response.  So why don't you go ahead and make a change to see what that looks like.  Edit `templates/root.erb` to look like this:

``` erb
<h1>Hello, World</h1>
<footer>
  &copy; Copyright <%= Time.now.year -%>
</footer>
```

If you make a request to your application now, you'll see this:

  	$ curl -s http://localhost:9393
  	<html>
  	  <head>
  	    <title>Hello, World!</title>
  	  </head>
  	  <body>
  	    <h1>Hello, World!</h1>
  	    <footer>
  	      &copy; Copyright 2013
  	    </footer>
  	  </body>
  	</html>

As you can see, the Ruby code contained between the `<%= -%>` was evaluated and the result what the current year, which was included into the response.  

One thing to notice is that you didn't have to restart your application, the changes were picked up automatically.  This is because we used `shotgun` to start the application, which handles automatically reloading the application between requests for us.

One question you may be asking is where did the `<html>`, `<head>` and `<body>` tags come from? `templates/root.erb` just contains the snippet that ends up in the `<body>`.  The answer is layouts, which is the topic we'll introduce next.

# Layouts

In many web application, the same `<head>` and basic structure within the `<body>` is shared among many different pages.  Layouts allow you to define that structure in one place and share it between multiple actions.  The layout your application is currently using is at `templates/layouts/application.erb`:

``` erb  
<!doctype html>
<html>
  <head>
    <title>Hello, World!</title>
  </head>
  <body>
    <%= render main -%>
  </body>
</html>  
```

The tag `<%= render main -%>` is used to specify where the main content for the view should go.  In fact, `render` is a generic method that you can use render any template from within another.  `main` is a local variable that has the name of the template for the current view, which is `"root"` in this case.

# More To Come

Sharp is still in the early stages of development, so keep checking back for updates on how to do more advanced things with Sharp.  

[jquery]: http://jquery.com
[bootstrap]: http://twitter.github.com/bootstrap
[bundler]: http://gembundler.com