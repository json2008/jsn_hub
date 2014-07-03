# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#
backend hz_hx_52 {
  .host = "10.0.1.52";
  .port = "80";
  .connect_timeout = 2s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 200;
}

backend hz_hx_57 {
  .host = "10.0.1.57";
  .port = "80";
  .connect_timeout = 2s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 100;
}
/*
backend hz_usr_2 {
  .host = "localhost";
  .port = "8084";
  .connect_timeout = 2s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 100;
}

backend hz_static_2 {
  .host = "10.0.1.2";
  .port = "8083";
  .connect_timeout = 2s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 500;
}

backend hz_zbx {
  .host = "10.0.1.101";
  .port = "80";
  .connect_timeout = 10s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 30;
}
*/

director new_hx_rnd random {
  { .backend = hz_hx_52; .weight = 1;}
  { .backend = hz_hx_57; .weight = 1;}
}

/*
director usr random {
  { .backend = hz_usr_2; .weight = 3;}
  { .backend = hz_usr_13; .weight = 1;}
  { .backend = hz_usr_14; .weight = 1;}
  { .backend = hz_usr_15; .weight = 1;}
}
*/

/*
director b3 fallback {
  { .backend = www1; }
  { .backend = www2; } // will only be used if www1 is unhealthy.
  { .backend = www3; } // will only be used if both www1 and www2
                       // are unhealthy.
}

backend server2 {
   .host = "server2.example.com";
    .port = "http";
    .connect_timeout = 1s;
    .first_byte_timeout = 5s;
    .between_bytes_timeout = 2s;
    .max_connections = 500;
   .probe = healthcheck;
 }

 probe healthcheck {
   .url = "/status.cgi";
   .interval = 60s;
   .timeout = 0.3 s;
   .window = 8;
   .threshold = 3;
   .initial = 3;
   .expected_response = 200;
   .request =
      "GET / HTTP/1.1"
      "Host: www.foo.bar"
      "Connection: close";
}
*/

sub vcl_recv {

 #   set req.http.x-in = now;

    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip; }
        else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    if (req.http.host !~ "\.(itlily|hotchanson|ttpod)\.com$") {
      error 403 {""Not allowed.""};
    }

/*
    if (req.url ~ "/data/user/p") {
       error 403 {""Not allowed.""};
    }

    if (!req.backend.healthy) {
       set req.grace = 5m;
    } else {
       set req.grace = 30s;
    }
*/
    set req.grace = 120s;

    unset req.http.Cookie;

    if (req.request == "DELETE") {
      return (lookup);
    }
/*
    if (req.url ~ "\.(gif|png|jpeg|jpg|swf|html|css|js|ico)(\?|$)") {
      set req.url = regsub(req.url, "(test.gif)\?.*$", "\1");
      set req.url = regsub(req.url, "^", "/" + req.http.host);
      set req.backend = hz_static_2;
      return (lookup);
    }


    if (req.http.host ~ "ttus\.ttpod\.com|u\.itlily\.com") {
      set req.backend = hz_usr_2;
      return (pass);
    }
*/
    if (req.http.host ~ "\.itlily\.com$") {
      set req.http.host = "h.itlily.com";
      set req.url = regsub(req.url, "\?.*$", "");
      set req.backend = new_hx_rnd;
      return (lookup);
    }

/*
    if (req.http.referer && req.http.referer !~ "(itlily|hotchanson|ttpod)\.com") {
       error 403 {""Not allowed.""};
    }
*/

}
#
# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
# sub vcl_recv {
#     if (req.restarts == 0) {
#   if (req.http.x-forwarded-for) {
#       set req.http.X-Forwarded-For =
#     req.http.X-Forwarded-For + ", " + client.ip;
#   } else {
#       set req.http.X-Forwarded-For = client.ip;
#   }
#     }
#     if (req.request != "GET" &&
#       req.request != "HEAD" &&
#       req.request != "PUT" &&
#       req.request != "POST" &&
#       req.request != "TRACE" &&
#       req.request != "OPTIONS" &&
#       req.request != "DELETE") {
#         /* Non-RFC2616 or CONNECT which is weird. */
#         return (pipe);
#     }
#     if (req.request != "GET" && req.request != "HEAD") {
#         /* We only deal with GET and HEAD by default */
#         return (pass);
#     }
#     if (req.http.Authorization || req.http.Cookie) {
#         /* Not cacheable by default */
#         return (pass);
#     }
#     return (lookup);
# }
#
# sub vcl_pipe {
#     # Note that only the first request to the backend will have
#     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#     # have it set for all requests, make sure to have:
#     # set bereq.http.connection = "close";
#     # here.  It is not set by default as it might break some broken web
#     # applications, like IIS with NTLM authentication.
#     return (pipe);
# }
#
# sub vcl_pass {
#     return (pass);
# }
#
# sub vcl_hash {
#     hash_data(req.url);
#     if (req.http.host) {
#         hash_data(req.http.host);
#     } else {
#         hash_data(server.ip);
#     }
#     return (hash);
# }
#
sub vcl_hit {
  if (req.request == "DELETE") {
      purge;
      error 200 {""purged in hit:"} + req.url + {"""};
    }
}
# sub vcl_hit {
#     return (deliver);
# }
#
sub vcl_miss {
  if (req.request == "DELETE") {
      purge;
      error 200 {""purged in miss:"} + req.url + {"""};
    }
}
# sub vcl_miss {
#     return (fetch);
# }
#

sub vcl_fetch {

  if (beresp.status == 308 && req.restarts == 0) {
      set req.http.Host = beresp.http.TryHost;
      set req.http.var_redirect = "true";
      set req.url = beresp.http.TryUrl;
      set req.request = beresp.http.TryMethod;
      return (restart);
  }

  unset beresp.http.Set-Cookie;
  set beresp.grace = 10m;

/*
  if (beresp.http.content-type ~ "(text|application)") {
      set beresp.do_gzip = true;
  }
*/

  if (beresp.http.cache-control ~ "(no-cache|private)") {
    set beresp.ttl = 120s;
    return (hit_for_pass);
  }

/*
  if (beresp.status == 500) {
    set beresp.saintmode = 10s;
    return (restart);
  }

  set beresp.http.x-url = req.url;
*/
}

# sub vcl_fetch {
#     if (beresp.ttl <= 0s ||
#         beresp.http.Set-Cookie ||
#         beresp.http.Vary == "*") {
#     /*
#      * Mark as "Hit-For-Pass" for the next 2 minutes
#      */
#     set beresp.ttl = 120 s;
#     return (hit_for_pass);
#     }
#     return (deliver);
# }
#
sub vcl_deliver {
  set resp.http.Server = "Lighttpd/1.4.32";
  set resp.http.X-Powered-By = "Google Go!/1.2.1";

  if (obj.hits > 0) {
      set resp.http.X-Cache = "HIT:" + obj.hits;
  } else {
      set resp.http.X-Cache = "MISS";
  }
  unset resp.http.X-Varnish;
  unset resp.http.Via;
  unset resp.http.x-url; # Optional
#  set resp.http.x-in = req.http.x-in;
#  set resp.http.x-out = now;
}
# sub vcl_deliver {
#     return (deliver);
# }
#

sub vcl_error {
    synthetic {"{"code":0, "status":"} + obj.status + {","msg":"} + obj.response + "}";
    set obj.http.Content-Type = "application/json";
    set obj.status = 200;
    return (deliver);
}

# sub vcl_error {
#     set obj.http.Content-Type = "text/html; charset=utf-8";
#     set obj.http.Retry-After = "5";
#     synthetic {"
# <?xml version="1.0" encoding="utf-8"?>
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html>
#   <head>
#     <title>"} + obj.status + " " + obj.response + {"</title>
#   </head>
#   <body>
#     <h1>Error "} + obj.status + " " + obj.response + {"</h1>
#     <p>"} + obj.response + {"</p>
#     <h3>Guru Meditation:</h3>
#     <p>XID: "} + req.xid + {"</p>
#     <hr>
#     <p>Varnish cache server</p>
#   </body>
# </html>
# "};
#     return (deliver);
# }
#
# sub vcl_init {
#   return (ok);
# }
#
# sub vcl_fini {
#   return (ok);
# }
