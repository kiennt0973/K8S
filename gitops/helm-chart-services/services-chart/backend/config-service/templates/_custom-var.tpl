{{- define "config-service.pvc-name" -}}
{{ default "default" (include "config-service.fullname" .) }}
{{- end -}}


{{- define "config-service.ingress-annotations" -}}
{{- $k8s_service_name := include "config-service.fullname" . -}}
{{- $namespace := include "config-service.namespace" . -}}
{{- $service_port := .Values.service.ingressPort | default 8800 -}}
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/cors-allow-origin: '*'
    nginx.ingress.kubernetes.io/enable-cors: 'true'
    nginx.ingress.kubernetes.io/proxy-connect-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-read-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-send-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-body-size: 500m
    nginx.ingress.kubernetes.io/send-timeout: '3600'
    nginx.ingress.kubernetes.io/server-snippet: |
      location ~ / {
        if ($request_uri ~* "seocache") {
          # set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/$scheme://$host$request_uri;
          set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/https://$host$request_uri;
          rewrite ^(.*) $new_uri permanent;
          break;
        }
        if ($http_user_agent ~* (googlebot|bingbot|yandex|msnbot|zbot|SkypeUriPreview|Discordbot/2.0|^WhatsApp|WhatsApp/2)) {
          # set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/$scheme://$host$request_uri;
          set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/https://$host$request_uri;
          rewrite ^(.*) $new_uri permanent;
          break;
        }
        if ($http_user_agent ~* (FacebookBot/1.0|facebookexternalhit|facebookexternalhit/1.1)) {
          # set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/$scheme://$host$request_uri;
          set $new_uri https://tmtrav-seo-dev.tma-swerp.com/render/https://$host$request_uri;
          proxy_pass $new_uri;
          break;
        }
        proxy_pass http://{{$k8s_service_name}}.{{$namespace}}.svc.cluster.local:{{$service_port}};
        proxy_set_header Accept-Encoding $http_accept_encoding;
        gzip on;
        gzip_types text/plain text/html text/css text/csv text/javascript application/xml application/xhtml+xml application/json application/javascript application/x-javascript application/ld+json image/svg+xml application/vnd.ms-fontobject application/x-font-ttf font/opentype font/ttf;
        gzip_proxied       any;
        gzip_vary on;
        gzip_comp_level 6;
        gzip_http_version 1.1;
        gzip_min_length 8;
        gzip_buffers 16 8k;
      }
      location = /robots.txt {
        allow all;
      }
{{- end }}
