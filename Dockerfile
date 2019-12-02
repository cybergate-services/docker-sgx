FROM debian:buster

MAINTAINER "Chinthaka Deshapriya <chinthaka@cybergate.lk"

WORKDIR /usr/src/sdk

RUN apt-get update && apt-get install -yq --no-install-recommends ca-certificates build-essential ocaml ocamlbuild automake autoconf libtool wget python libssl-dev libssl-dev libcurl4-openssl-dev protobuf-compiler git libprotobuf-dev alien cmake debhelper uuid-dev libxml2-dev

COPY install-psw.patch ./

RUN git clone -b sgx_2.5 --depth 1 https://github.com/intel/linux-sgx && \
    cd linux-sgx && \
    patch -p1 -i ../install-psw.patch && \
    ./download_prebuilt.sh 2> /dev/null && \
    make -s -j$(nproc) sdk_install_pkg psw_install_pkg && \
    ./linux/installer/bin/sgx_linux_x64_sdk_2.5.100.49891.bin --prefix=/opt/intel && \
    ./linux/installer/bin/sgx_linux_x64_psw_2.5.100.49891.bin && \
    cd .. && rm -rf linux-sgx/

WORKDIR /usr/src/app

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# For debug purposes
# COPY jhi.conf /etc/jhi/jhi.conf
