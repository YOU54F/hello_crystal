FROM 84codes/crystal:latest-debian-bullseye as builder

WORKDIR home
ADD bin/ /home/bin/
ADD lib/ /home/lib/
RUN crystal run ./bin/fetch_ffi.cr --no-color 
RUN ls -al
RUN apt-get -y update && apt-get -y install file
RUN file libpact_ffi.so
RUN crystal build --release --link-flags="-L$PWD" ./bin/ffi.cr
# RUN crystal build --release --static --link-flags="-L$PWD" ./bin/ffi.cr
ENV LD_LIBRARY_PATH=/home
RUN du -sh /home/ffi
RUN file /home/ffi
ENTRYPOINT [ "/home/ffi" ]
# ENTRYPOINT [ "/bin/bash" ]

# FROM alpine:3.6
# COPY --from=builder /home/fetch_ffi /home/fetch_ffi
# WORKDIR home
# RUN du -sh /home/fetch_ffi
# ENTRYPOINT [ "/home/fetch_ffi" ]
# FROM ubuntu:latest
# COPY --from=builder /home/fetch_ffi /home/fetch_ffi
# WORKDIR home
# RUN du -sh /home/fetch_ffi
# ENTRYPOINT [ "/home/fetch_ffi" ]
# FROM busybox:latest
# COPY --from=builder /home/fetch_ffi /home/fetch_ffi
# WORKDIR home
# RUN du -sh /home/fetch_ffi
# ENTRYPOINT [ "/home/fetch_ffi" ]
# FROM centos:7
# COPY --from=builder /home/fetch_ffi /home/fetch_ffi
# WORKDIR home
# RUN du -sh /home/fetch_ffi
# ENTRYPOINT [ "/home/fetch_ffi" ]