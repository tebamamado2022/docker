 FROM debian:buster

# Maintainer information
MAINTAINER Odoo S.A. <info@odoo.com>

# Install dependencies, lessc, less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    node-less \
    node-clean-css \
    python-gevent \
    python-pip \
    python-pyinotify \
    python-renderpm \
    && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-buster-amd64.deb \
    && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
    && dpkg --force-depends -i wkhtmltox.deb \
    && apt-get -y install -f --no-install-recommends \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
    && pip install psycogreen==1.0

# Install Odoo
ENV ODOO_VERSION 8.0
ENV ODOO_RELEASE latest

RUN curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && dpkg --force-depends -i odoo.deb \
    && apt-get update \
    && apt-get -y install -f --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/odoo/



COPY ./c_addons8 /mnt/extra-addons/


RUN chown -R odoo:odoo /mnt/extra-addons

RUN chown odoo:odoo /etc/odoo/openerp-server.conf




# Set up volumes for persistent storage
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]

