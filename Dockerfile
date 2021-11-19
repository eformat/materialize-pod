FROM registry.redhat.io/ubi8/ubi:latest
USER root
RUN curl -L https://binaries.materialize.com/materialized-v0.9.13-x86_64-unknown-linux-gnu.tar.gz | tar -xzC /usr/local --strip-components=1
RUN chmod 755 /usr/local/bin/materialized
EXPOSE 6875
WORKDIR /work
RUN chmod 775 /work
CMD ["/usr/local/bin/materialized", "--workers=2"]
