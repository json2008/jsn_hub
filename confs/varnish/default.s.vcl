# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#
backend hz_var {
  .host = "10.0.1.2";
  .port = "80";
  .connect_timeout = 2s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 100;
}

backend hz_zbx {
  .host = "10.0.1.101";
  .port = "80";
  .connect_timeout = 10s;
  .first_byte_timeout = 15s;
  .between_bytes_timeout = 5s;
  .max_connections = 30;
}

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

    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip; }
        else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    if (req.url ~ "^/zabbix") {
      set req.backend = hz_zbx;
      return (pipe);
    }

    if (req.http.host !~ "\.(itlily|hotchanson|ttpod)\.com$") {
      error 403 {""Not allowed.""};
    }

    if (req.url ~ "/data/user/p") {
       error 403 {""Not allowed.""};
    }
/*
    if (!req.backend.healthy) {
       set req.grace = 5m;
    } else {
       set req.grace = 30s;
    }
*/
    set req.grace = 30s;

    unset req.http.Cookie;
    set req.backend = hz_var;

    if (req.url ~ "\.(gif|png|jpeg|jpg|swf|html|css|js|ico)(\?|$)") {
      set req.url = regsub(req.url, "(test.gif)\?.*$", "\1");
      set req.url = regsub(req.url, "^", "/" + req.http.host);
      return (lookup);
    }

    if (req.http.host == "ttus.ttpod.com") {
      return (pass);
    }

    if (req.http.host ~ "(h|s)\.itlily\.com|ting\.hotchanson\.com") {
      set req.http.host = "h.itlily.com";
      #set req.backend = hx;
    }

    if (req.http.var_redirect) {
      return (lookup);
    }

    if (req.url ~ "^/favorites/(create|destroy)\?.+$") {

      if (req.url ~ "callback=" || req.url ~ "v=v4\.(0\.2|0\.3|1\.0)") {
      } else {
        error 701 {""version error!""};
      }

      set req.http.x_qstr = regsub(req.url, "^[^?]+\?", "");
      set req.http.x_qstr = regsub(req.http.x_qstr, "^", "&");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&(access_token|song_id|callback)=", "& \1=");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&[^ ][^&]*", "");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "& ", "&");
      set req.url = regsub(req.url, "\?(.*)$", "\?_t=1") + req.http.x_qstr;
      return (lookup);
    }

    if (req.url ~ "^/songs/plaza.*\?.+$") {
      set req.http.x_qstr = regsub(req.url, "^[^?]+\?", "");
      set req.http.x_qstr = regsub(req.http.x_qstr, "^", "&");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&(version|page|size|tag|area|type|song_id|callback)=", "& \1=");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&[^ ][^&]*", "");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "& ", "&");
      set req.url = regsub(req.url, "\?(.*)$", "\?_t=1") + req.http.x_qstr;
      return (lookup);
    }

    if (req.url ~ "^/songs/(download|pickcount|ting)\?.+") {
      set req.http.x_qstr = regsub(req.url, "^[^?]+\?", "");
      set req.http.x_qstr = regsub(req.http.x_qstr, "^", "&");
      set req.http.x_qstr = regsuball(req.http.x_qstr,  "&(song_id|callback)=", "& \1=");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&[^ ][^&]*", "");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "& ", "&");
      set req.url = regsub(req.url, "\?(.*)$", "\?_t=1") + req.http.x_qstr;
      return (lookup);
    }

    if (req.url ~ "^/favorites/(list|songids)\?.+") {
      set req.http.x_qstr = regsub(req.url, "^[^?]+\?", "");
      set req.http.x_qstr = regsub(req.http.x_qstr, "^", "&");
      set req.http.x_qstr = regsuball(req.http.x_qstr,  "&(access_token|size|pick_time|tuid|callback)=", "& \1=");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&[^ ][^&]*", "");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "& ", "&");
      set req.url = regsub(req.url, "\?(.*)$", "\?_t=1") + req.http.x_qstr;
      return (lookup);
    }

    if (req.url ~ "^/songs/plaza/version/check\?.+") {
      set req.http.x_qstr = regsub(req.url, "^[^?]+\?", "");
      set req.http.x_qstr = regsub(req.http.x_qstr, "^", "&");
      set req.http.x_qstr = regsuball(req.http.x_qstr,  "&(version|size|callback)=", "& \1=");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "&[^ ][^&]*", "");
      set req.http.x_qstr = regsuball(req.http.x_qstr, "& ", "&");
      set req.url = regsub(req.url, "\?(.*)$", "\?_t=1") + req.http.x_qstr;
      return (lookup);
    }

    if (req.url ~ "^/tag/plaza\?") {
      set req.url = regsub(req.url, "\?.*$", "");
      return (lookup);
    }

    if (req.request == "DELETE") {
      return (lookup);
    }

/*
    if (req.http.referer && req.http.referer !~ "(itlily|hotchanson|ttpod)\.com") {
       error 403 {""Not allowed.""};
    }
*/

/*
    if (req.http.Accept-Encoding) {
      if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
          # No point in compressing these
          unset req.http.Accept-Encoding;
      } elsif (req.http.Accept-Encoding ~ "gzip") {
          set req.http.Accept-Encoding = "gzip";
      } elsif (req.http.Accept-Encoding ~ "deflate") {
          set req.http.Accept-Encoding = "deflate";
      } else {
          # unknown algorithm
          unset req.http.Accept-Encoding;
      }
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
      error 200 "purged in hit:" + req.url;
    }
}
# sub vcl_hit {
#     return (deliver);
# }
#
sub vcl_miss {
  if (req.request == "DELETE") {
      purge;
      error 200 "purged in miss:" + req.url;
    }
}
# sub vcl_miss {
#     return (fetch);
# }
#

sub vcl_fetch {
  if (beresp.status == 308 && req.restarts <= 2) {
      set req.http.Host = beresp.http.TryHost;
      set req.http.var_redirect = "true";
      set req.url = beresp.http.TryUrl;
      set req.request = beresp.http.TryMethod;
      return (restart);
  }
  set beresp.grace = 10m;
/*
  if (beresp.status == 500) {
    set beresp.saintmode = 10s;
    return (restart);
  }
*/
  unset beresp.http.Set-Cookie;
  set beresp.http.x-url = req.url;
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
  set resp.http.x-ip = client.ip;
  if (resp.http.x-ip ~ "^10\.0") {
    set resp.http.x-ip2 = "uu";
  }
  unset resp.http.X-Varnish;
  unset resp.http.Via;
  unset resp.http.x-url; # Optional
}
# sub vcl_deliver {
#     return (deliver);
# }
#

sub vcl_error {
    set obj.http.Content-Type = "application/json";
    if (obj.status == 701) {
      synthetic {"{"code":1,"msg":"} + obj.response + "}";
      set obj.status = 200;
    } else {
      synthetic {"{"code":0, "status":"} + obj.status + {","msg":"} + 444 + "}";
    }
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
