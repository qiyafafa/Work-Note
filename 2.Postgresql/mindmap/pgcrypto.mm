
<map version="0.9.0">
    <node TEXT="[pgcrypto](https://www.postgresql.org/docs/10/static/pgcrypto.html)" FOLDED="false" POSITION="right" ID="5b7cdd70875cc69b28148374" X_COGGLE_POSX="0" X_COGGLE_POSY="0">
        <edge COLOR="#b4b4b4" />
        <font NAME="Helvetica" SIZE="17" />
        <node TEXT="PGP Encryption Functions" FOLDED="false" POSITION="right" ID="81dc16e932574992c9761c3a50bb25df">
            <edge COLOR="#9ed56b" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="The functions here implement the encryption part of the OpenPGP (RFC 4880) standard." FOLDED="false" POSITION="right" ID="054af694dd8d07186c0793d631abad6a">
                <edge COLOR="#a0d36d" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
        <node TEXT="general 
hashing functions" FOLDED="false" POSITION="right" ID="10d5698913a5bfcfbaa86bb9fcacf1e9">
            <edge COLOR="#7aa3e5" />
            <font NAME="Helvetica" SIZE="13" />
            <node TEXT="digest()" FOLDED="false" POSITION="right" ID="b30995c502d205c08e32d9b6217d61c5">
                <edge COLOR="#7aa5e5" />
                <font NAME="Helvetica" SIZE="8" />
                <node TEXT="usage:
digest(data text, type text) returns bytea
digest(data bytea, type text) returns bytea" FOLDED="false" POSITION="right" ID="af8b0400b1bccb96b4ba8237c5bb5aa0">
                    <edge COLOR="#73a3e6" />
                    <font NAME="Helvetica" SIZE="8" />
                </node>
                <node TEXT="method encode: cast the return bytes to other format string" FOLDED="false" POSITION="right" ID="9f890921d65439b54adc2b2f1e790ccf">
                    <edge COLOR="#74a2e3" />
                    <font NAME="Helvetica" SIZE="8" />
                </node>
                <node TEXT="compiled with openssl: alorithms: DES/3DES/CAST5, Any digest algorithm OpenSSL supports is automatically picked up. This is not possible with ciphers, which need to be supported explicitly." FOLDED="false" POSITION="right" ID="5fa037cd92b554b20fc79aeaf0e0cc53">
                    <edge COLOR="#75a3e2" />
                    <font NAME="Helvetica" SIZE="8" />
                </node>
                <node TEXT=" Standard algorithms are md5, sha1, sha224, sha256, sha384 and sha512" FOLDED="false" POSITION="right" ID="09c7d5c6a748a5fde7eb45d95870d15a">
                    <edge COLOR="#6fa0e4" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="Computes a binary hash of the given data. " FOLDED="false" POSITION="right" ID="5acaf3adad0b2c977d23983878b68c8d">
                    <edge COLOR="#77a5e4" />
                    <font NAME="Helvetica" SIZE="8" />
                </node>
            </node>
            <node TEXT="hmac()" FOLDED="false" POSITION="right" ID="34ac3eabf1aaa5db0c26b5638a071509">
                <edge COLOR="#73a1e6" />
                <font NAME="Helvetica" SIZE="13" />
                <node TEXT="usage:
hmac(data text, key text, type text) returns bytea
hmac(data bytea, key bytea, type text) returns bytea" FOLDED="false" POSITION="right" ID="ba2bd2e127f60c058ee7aecac4cdd7f1">
                    <edge COLOR="#6a9ee7" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="Calculates hashed MAC for data with key key. type is the same as in digest()." FOLDED="false" POSITION="right" ID="ace7f6b913103efaa79a32bf78de83b3">
                    <edge COLOR="#71a2e6" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
            </node>
        </node>
        <node TEXT="Notes" FOLDED="false" POSITION="left" ID="9461a269a4109d5b03b8e89ab6b737db">
            <edge COLOR="#efa670" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="configures
--with-zlib
--with-openssl" FOLDED="false" POSITION="left" ID="760abfd499c3bdf395e53c60297d2a5e">
                <edge COLOR="#f0a16b" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
        </node>
        <node TEXT="Raw Encryption Functions" FOLDED="false" POSITION="left" ID="78a2de8c68abc9f0a9ce789b50e20f62">
            <edge COLOR="#ebd95f" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="These functions only run a cipher over data;" FOLDED="false" POSITION="left" ID="bbf0f89779d6050b443f5456567f43b4">
                <edge COLOR="#ead662" />
                <font NAME="Helvetica" SIZE="13" />
            </node>
            <node TEXT="" FOLDED="false" POSITION="left" ID="cf2fe806826129fb3aa9a1c0ca708f3e">
                <edge COLOR="#e9d55f" />
                <font NAME="Helvetica" SIZE="13" />
                <node TEXT="encrypt(data bytea, key bytea, type text) returns bytea" FOLDED="false" POSITION="left" ID="484595715591914301a6ac5efa08c0c4">
                    <edge COLOR="#e6cf56" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="decrypt(data bytea, key bytea, type text) returns bytea" FOLDED="false" POSITION="left" ID="0557f9056b092fdaa8d95a30fd460193">
                    <edge COLOR="#e7d15f" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="encrypt_iv(data bytea, key bytea, iv bytea, type text) returns bytea" FOLDED="false" POSITION="left" ID="d9e431500ff959ef3b8cd181e7b23c1e">
                    <edge COLOR="#ead466" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="decrypt_iv(data bytea, key bytea, iv bytea, type text) returns bytea" FOLDED="false" POSITION="left" ID="d576cab430c010c26c683d2efa459012">
                    <edge COLOR="#e7d15d" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
            </node>
        </node>
        <node TEXT="Password 
Hashing Functions" FOLDED="false" POSITION="right" ID="fd6c334e3bece9b1dae409fec3ef10b8">
            <edge COLOR="#67d7c4" />
            <font NAME="Helvetica" SIZE="15" />
            <node TEXT="crypt()" FOLDED="false" POSITION="right" ID="68b04f4eec74d1239ae4229b5c864b0f">
                <edge COLOR="#6cdac6" />
                <font NAME="Helvetica" SIZE="13" />
                <node TEXT="does the hashing" FOLDED="false" POSITION="right" ID="ce3e07afe693d15325dcc88409be009b">
                    <edge COLOR="#6cdcc6" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="Algorithms : bf, md5, xdes,des" FOLDED="false" POSITION="right" ID="1bb057ca83d4d370f218979f6688bead">
                    <edge COLOR="#71ddc8" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="Usage:crypt(password text, salt text) returns text" FOLDED="false" POSITION="right" ID="f1e5bd95bc34bb1999213d2fd969ff69">
                    <edge COLOR="#60dac2" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="set a hash password:  
create temp table test(pswhash text);
insert into test select crypt('ddd', gen_salt('md5'));
authentication when login:
select (pswhash=crypt('ddd',pswhash)) from test;" FOLDED="false" POSITION="right" ID="57e7a8b4a9a365807c7ecff954836ab4">
                    <edge COLOR="#74dcc8" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
            </node>
            <node TEXT="gen_salt()" FOLDED="false" POSITION="right" ID="d14fdd1973960a382fadd1ea25604337">
                <edge COLOR="#68d8c3" />
                <font NAME="Helvetica" SIZE="13" />
                <node TEXT="Generates a new random salt string for use in crypt(). 
The salt string also tells crypt() which algorithm to use." FOLDED="false" POSITION="right" ID="a7b16406edc28f8cb6639d7ae5c6542c">
                    <edge COLOR="#6bd7c1" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT="gen_salt(type text [, iter_count integer ]) returns text" FOLDED="false" POSITION="right" ID="d14e883f5bb7edf2fd34f957ca216612">
                    <edge COLOR="#66dac2" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
                <node TEXT=" ![crypt](https://coggle-images.s3.amazonaws.com/5b7cdd70875cc69722148371-4f00474c-e181-4389-afb9-004b5a533018.png 150x59) " FOLDED="false" POSITION="right" ID="ab52ae346a6b555c93a308bd281f34df">
                    <edge COLOR="#6ed8c2" />
                    <font NAME="Helvetica" SIZE="12" />
                </node>
            </node>
        </node>
    </node>
</map>