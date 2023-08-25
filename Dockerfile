FROM 84codes/crystal

WORKDIR home
ADD bin/ /home/bin/
ADD lib/ /home/lib/
RUN crystal run ./bin/test.cr
ENTRYPOINT [ "/bin/sh" ]