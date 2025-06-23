module.exports = {
  apps : [
    {
      name   : "frontend",
      script : "./frontend/server.js",
      watch  : true,
      env_production: {
       NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "merchandise",
      script : "./merchandise/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "products",
      script : "./products/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    },
    {
      name   : "shopping-cart",
      script : "./shopping-cart/server.js",
      watch  : true,
      env_production: {
        NODE_ENV: "production"
      },
      env_development: {
        NODE_ENV: "development"
      }
    }
  ]
}
