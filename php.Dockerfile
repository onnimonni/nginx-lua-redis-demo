FROM alpine:edge
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@keksi.io>

RUN \
	##
    # Install php7 packages
    # - These repositories are in 'testing' repositories but it's much more stable/easier than compiling our own php.
    ##
    apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ \
    php7 php7-fpm php7-json php7-redis php7-opcache

WORKDIR /var/www/web

ENV PORT=9000

RUN set -ex \
	&& cd /etc/php7/ \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo "listen = [::]:${PORT}"; \
	} | tee php-fpm.d/zz-docker.conf \
	&& { \
		echo '[opcache]'; \
		echo 'opcache.enable = 1'; \
		echo 'opcache.memory_consumption = 128'; \
		echo 'opcache.max_accelerated_files = 1000'; \
		echo; \
	} | tee conf.d/opcache.conf

EXPOSE ${PORT}
CMD ["php-fpm7"]