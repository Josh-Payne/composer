ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ]�$Z �=�r��r�Mr�A��)U*�}��V�Z$$Ey�,x�h��DR�%��;�$D�qE):�O8U���F�!���@^�3 ��Dٔh�]%�����tO�L�Yj��!�j�-�����m�3�p�e<� �q�~F�0�� *ʏĨ$�bT��#A�K��#$�S�����F�k�3ݹoZ��Έ�薹�V��s�}���Y�8��9a��w��t�n���[d���2��CZ��&�A�:�#���)�Pۖ�:>I�BheMX���$nǲ�,W#5���H�]b�����}��}��5BWm]i�,DfC���2�H�n�����Q�eQ�ؽs2�r��0�.��fu��
;�Y�`��y�EIz����8�B���?x�HU7#U�48��l� ~�)R5���6յ��2���ޗwJ��������P�����{���a�,��
&�?�}:��U���B�����a���6�.�#�V��n���M	�M�%!��� ����b��,���	���j���c��R���o��E�#��b��\r�T��u�_��*�6�(�¢�'k�Qm��Y[�h�Y��\Ѯu��`W�6%:��Y6���a�[�t��t\��l��Tܶ�3X���k{�%��uײ��z�6�xj��u���$�6hJ�u��z$9�V�Vd�&�kY�����{nòYÆ�J���JL�խ��4HH
��$ݎek��Y���eհԦ����Kq,ã�PF�1J~';��V=��B�V�qX�=��B!�Q����l����A���3�ML���N�hRLJ��p2,��������g�a9h]/�7�I����@	ȡ�sW���˃[��ȰӁY]�)������dI�E2��DQZ��y����=A��C5�T�Bn���¦�lҲ�$d{���������9��~����=qc��Ʀj;(�����jM�`A�a�<z���4AE�a!~ꣴ1T{����(6bz�A�
���2Wӡri�r<\�tc�%��^�w��n!F�j��+ڋ�~Zý�NI��!@��c>
볽�����6�q��m��!�}9X�i�}�j;���<5-���LZ���-������Bh{lY��e2Կ�4}s8��Ks{;VD�> r���B�w͂�]���p{���g����.�4t��,fؠ�������S69��u6�^'(�9O+�q���t�[@����8� &�5Z�2�	ε���U�)o�x1@����w͋�k�G�u7H'V9�2�be�Za��O'ҽ��R����x,]��������0��T��e�y��xB����bb!�� �N��a|���s`[4,=j�ٖ�s��ݴqշ�<ۦ@i��c�].�/m|�6�*[���r��߫l��������+�������
e��ʡ0rsJ��O�?̖�������ؼ#Hw�g:�]��Z���Q;y�?��Kh��d�!7���XY�f��r��rE)U�W���A�f�G�&�.��S��`iγkM)�!��6P��&+|#���/��`����<��?�e��w�P�#a�卬��"X��^�Jl��Az��R$Ҳ�O�4t�CG�n�I�.�E����P��Y�Ek؍�=On϶��,��4�O�'���Daq�?���y�L~����:�8��k��i�f[-t&��XX@(��=��|��"}`���a۽Op��GEa��Kȋ�߹���?��S;'f��t�0P(ڡ����B��K���&����4{��b�E��<`��3g�Y0M��?�%������]��K���Dtt�G�F�.0v���n�e�n;."�m٫�m���Z�Ԝ0G]�9��=q�YG��<�pJ)���ǖ�P�۷��Od��e�����K��Es����1F�=�(0"�����pTڻ�B��z9�?pf�LY���i��#���B!���	�c��&a'�`
1�)F{�&���'��PE,�H�4�F��a�8x�̙j�������uxm��A*8h����-�]��,�B����٣�?|b�������\`v����j�9j�=/qq�ץ�E�N8����^s�p Zz84��mB�u� �İ������Ub�}L���#9�<��UG��>�w��Y.�L���,����_ ������`����0'}�n�0S�����p/߬�)z<����(�FG/醱L���������6t"���z��N�ra�r	T�.K?��g�Q�Պ�dz8�����8t7tȵR�l�����������fhP���~��~�
���!�Dq��Ǐ��|�N�c����=ck:�'��Y$D��f|FF	�n�$_4��c�pC��'��I0\�v��N������'��͡�(���L�u�U�A�{�)��h0�Hb��� �~�?���v[]�D�Eݰw=!�]1�w�p����ed~u���Ö]������6ТK�3A}?��&<X�J;�����/B�@�n)���ck`�^֨ި������gh�.4�P�����"��BNT�+ƌ��J�C��}��=޸�%�B�m�uNjz=B�hbS��,�12�eϡ�
[5~��	�E����(�W��Wk��X�
k��$��ruMM�R�D�X|MÂ��k	���	��X�c��N�KgK��p��u�����B43�&-v�?Ph�p"�
������&;�ם��XY��pO(MEs�WF(Ԟ,�(�h��J�5�>�ѡ&6L�fc�(�O��w��9V�_a��gz��"L+�$��'�� d���!^%X"@�3��h<w}L��ϧ���7KP�4�/&��IRL^�������l2۲��.�F�w��S��/36���|�j����O
�z�+��?*�`������Y��a����8}|?\��]pj��F� ��eh�=�F��\�	�R����ڞ� (Txc!ʈo��a'��44��o<q���k7�d���u�ns���M#Zv�rk����<#�{��xp������2&��$�g��?+���>�% ��k����Ý������:��18�Rl�1���(1_=���iu����/B,!���XLX�� �����s�����}�?�����W�ߏ�??�L�UA�e)�VSEU���V���Z2�U��,%0�E"��d5�U,'cɤXM�Ť�Z,���r��'��,���J�mНc0D���︿���ң�9.m��e���Z�ǥ��z+� ����f��ߌ��o��f@��߱m g韗�X�z�M���_�����?-=���'��6�	z8?�w��s��/�����:>>�/
�?�����ޥ�)�_��_��
�����8��\>�Q~���i}O��-�>-��L�������~�KL�7���2��Ꭷ��<=/��z�9>nPf=�*�>�K~���(����"�g�\>�T�,��Y��ӛ�鴢��J'�R���R�v����Imv��	��6��N�~�߶N��Bp;�Ev((�ME<Ȧ���a�<{��R��!�����Fu�hU��<|�=ϝ*~�Z�B���|k���w,����fEy�cX��f�{r��N^7��)�;�J��VF�>N�������Nk"fg���S<�K�J^ح�#�v�҄^�[��4U-�;���q�p3�yuxp����h�ҩ����s��əڊ��+٣Bj�o�y���<�r^>{�=>�������E�VH	C�t���J.>�)�f�3�f�U7ύ�V�ZI�@O�
����rAN*��f:|�d�!��6����Ծ��</W
���Y��Z?�>:�����Q��*�e�4�F�v�����ʺ+$N'�Nf�XN䝂�W�����f��}Z��v
�c�j�N6���1ުg���R!��ֲʩ��m����7�m%�j�'�K���[�.�4;ۭ�H@���B:/�ҫ��r��X���������~Zv���o�t���Z9&��HƎ���y�<���H�<:�&��Z����c�q�U|�լ��m�l�SH&��[��aakz7-'gZ�l�5ٔ�3Ā���
G�w,������1C����c�������(2���@��@O�ۖ�ކ7-�W
���Ϫ�C�Ɏ������O����������X����IA������\!��k�r���:��P��uA�wvvRۖI��j�1w��
e�5)nƙ������oJ^L����쳴�P,�͋N'�_ʭ�a=���cN>lt�K�n,g���ᖴ��Ӎ#����ʮD$�*�́���lU�"�B�*�s���z�>w�90���f��:��?���b�E��|�?���M�f���Y�$nV���E�f���Y$nV����=�f���Y�#n�o���}Eq�_��'_��b�o���?������G_��'M���s�a�� ��O��f'�9�
캴�߷�2ʾ�ٯ+Y����\� Wr�
�Gu/��U���Z�ǜ��;��Y�z����a��lX�b�����k�-S��;��9�[m�^��R��v��9�ܽ�ہO����4�.��[���ܿ�=|�����_�OP�jwm�O���#�0P��9�Dؼ���e��y���z���j:�����7����������v��QeHM7u1k�hT��*ja��U� j���xq�,�C_J}��)����BE���Ae���u4_���nJ�/���F�L��E{U�auX*U5���������e�[�������O�^{�<�id�L�'5��N޺82s���z�>��^���(�{�q�M2��U�t9��n�"2<�hd:�΀��g���ڳټ
#T �n��}�Q��a��i�݇]��K�O!�ÚM �M�mwi�4�rm�8@;k� �K�vؽ}@u;����y{2&q=-����3Ti0�?X�(�*r���{�����>�Ln<�e*�/t��A����~Z`�غƮ��	�-�.B�R]���3�Ut�Q��#=v+��^㯮��˟�WW��D�w�T�6���4�=B�2C��'M�r%���Ud���{�ױ��{���nz���f0��o�{�;�b�4v�$N��:�JX���q\q�T��I�F�B���i@�A�@�CblaX ��ĂB�5�{���J}^��ꖦ��R��������{�9�hs�\>�1Ԏp����[H3Fޤ�K�!H9�·ו范�d榣�A�`r���G�����\���gg�yzN���K@�7�_�jg�k�h����1��)<V�.M�S-�"b�k4�抹�"ēCx|�JL��Oc�yu�Sz������yDhױf@�-�t	[鹊�-D����۞k7�E�����	������\W@��Lg=ρ"��9���	V,@�!oDn�<f�͜�Tz��TxE�4��X����t/��]����C�^�_V��{9����ư�u�j|�2M��!̑6x�M۾�Q7�}��$�[9����U����' ��&7GN-��)��H
e+.�z�i,�*��c�x���Z���5A�,���C��@BۏQ��x�OP���������q+���,|���g��7�����M�:��2��F��������~��O�5�����O`K�7��Ƌ^��ctW�U�u��4ԏ�K������	�J��TZ#�D�J+j��j):�P*KS�,IktF%H��˙,�&��Tbb�|������7O�'�O�G���­~F����Nb�������N"�Ooa��oQر�y+���v]��������_��7��}�kb����������>���}s��_A4t�1x�k���Ε�� �i�9f)[�h���s����`xR���s®��1vݳ�����wE�����g�|Od-�|y!J��a�32Z�M,*+�O:�N�']�-��z���Eq�[1%�p�#1�$6D���&�����(�TF�@lt�<��y��@(�1.�Qe�#+s�1t�.�p�/X��ޢ<:�:m�U
�Y��:b�u:��a��r�iһ3^a��I"�a��ph�	��Ғ���A���.���igb+�2Z�ĴM�a��R��(�l���+�&q�εB���\�����f65�^���{�0�:/���Nc���r.�,y�[.��W����)^��zAv�Ӵ��E��gs*���n�v��ׅ#kY����6�� d���rz7['ۑy]t�E6cҫ=��JM��	����Y�gzN(������f�i0�q��O��T]8��0�$���̡݌_pv��.��;��;���>��u��f�!c��O:U��K	��A���~~$�,{�"R�J7a6r��Y�C~)bg����+ʞ/"z0�(;�=�=�=�*����݄R�����s4�j��8�(�K��%�{]��t�t�-�z'Ks��l�HUE%mR<*1�)�0�B�ʷd��pM5[;��5q-�O�S��,�?�"~�]����,���l���WGU�6�bUfNV.�K�B�M�����T�J`3>�MiĈ�uڭ�l�s��N[�K:�2=�	�Q9��9�R�_��V�U��j���sr���F�Lj�_@e��xx����/�{1�v�^����{/<x������@b}���%�{�W+��.���?/��S�e�e��k�������q?_�?�����{���~�b�@[^��{!l�y�b�6l-J�}��ؿ}�r�~���|?����߿���q)++� +S���̼*�[c��
�n��~�̗��-���d~�ܦ����ǻ4$yĹ��h�"��®�5G9汮���>�r�m|$���W!�j(TQ�#�z��"˺���4�f�ή�|1=K�R�=nR��'u,��Q������(!(��1JԺ����br#E�ٓ��,�cg����(_�aR:����IL��2$�X�;G2�t�����w�cjQ}���L�q1�pA�����XY�W#�e��������^:���p�Œ��֠���9�6�^)2�3ci�a���Ҡ5	I;JSã*� �����h�r{PBtQ����]��D|���ej{����NJT�'�f3>]
���"}��o]J49�(+��\�����Y��g�U[��3����Kd�@������9dnT�����8�O�\gY9�n���H�4.LsO�r@��u�= w��'L�o���C�m�ꅫ�p,��\���ձ�v���u٬�kd�`K��a����M�R���F�5�ګ���0�Q֜��u�X\�օ3���a�[aR��i�"���1"�z�2�)�9�a��XN�\�,Fo�"m��%���b����^�=8= k:��c$�:�\�$��M �Q�(�zG��V�j�b{(��	_j��%�M�w$�vE��h4$@0:'Q�B��抆���~o�t���R�H�R�N[�Ҫ��t⿺�&*$˵ +�Q}2>2�3�Ȳeu '�3Z��p�+H,����d��G���Xp�0���l�_(Ld��I��@��k��J�4N�[����d�N������=�S��N�����dfޭ7��W{҄�M&��T�4딉J�l���A!i�2���eV�)�(�(X Qv�t�ܑN�{l�t�re�h�c�����b��;��E��bC����
K�F3�:U���bF��a��J��QvQc�#�2IZ#��Xa�F+.�ns�I���lj��W�.�(s)u��v�Y��*1�zir��~��D���c�EU���W/�\��W.������uцf;S�;��2>�U���n�6�g���h�7b�`/ۖi�Yb?��No�4VZ��ث��7�>}J���)����#y��b��^�^"מ}>ƾ��3�C�4Tχ��tEoB�z%
��}썢l��Θ� FP��|���������~�&:�M����?�|=�.`o��è�T�m͎ѱ�;��S�(yt<w-��=�����E�k��A{"gq5�_�\r��H%���������m<7c��ѻ��A���z����~_C~�7,�/�62�P4\CQ�T| 2�sx�d��a*%��D��#�A��-?����M�,V��������0߰	Q��c�1{p��v���|�;����γ��72l���,��q�x�����n9{�z�%5�����!HO���h���z�l�;�&����zSH��L��7�����|C����ò������g1m�4��S�j�=Sh1�F��T�&P}k��@�g�wa��14F|�B!/�ſt�ゃ�kf��X2v
v��D���/e�< :_[�!�*�0�X�y��I����m.lat�1��j�7ڇ<h�zR����z�iM��6�Sk��e6��a�"��.�A��1��X/p!�)
��i`ۊX��s";�k~`;�dwB`�}|3���<�g+�N�A@��։}H3�2.C�Eߓ�	@ݰ65�=c"��x�E^d���T��JN'�/מHt̀]2�W�{t塇��>�(Ӹ7������}7�jc����6�x�0�(ͯ!�$S˶��|1&(l�l���>�E�o������Zcߢu+P�	��pd�$FKȡ!qhg�gA��z�8cؼ%pj���>�oN��9I�V�׀.�5��9���
��	�O�8ЏǶ�����!N�_ɚj&�l]+\7#m<M)d��������ό3h �D� ����de�P�e��.c���!�C�/���>���왝�Ux5�,^��{M	����As�.�ocx�G��1���ʆDD�P�ʸ�"8ѽ�}��7�Í�g���e�[��#�d AC��P M�8��!Q�.ze�6�#ya�f�] �m:]�����#�&/|h�r"Z��q���e�do�����*0�pb���u�B^�M��R�M\7����U�����\d���!�^l�j�$|��ۇ3A2P��0����ƃZ#A�~�� * �� �����#��z@h���9�t����ZC(@�Q�<�u�W���p"��2�#�*U��G9��>�57��M�$�k�Md�q�#���,����y�j4т��fAN�1M�_P:���<��m��8�:�Xs\k:��Ʀ��ܙ��ȱ�rDpގ8����w�oj��}������3���qvi�����dr+��L��������@~�a����숹��JL}�
�a�Ȃg}�:ϰ!w�c�ad�'q���w��qrG�&�8��[� v4{��R��,/��P�z�z^��+:�;�V�L���O�)��e�NgIM��Z��R�^O�j�O�2�$��,�*}��M���d2%�(�h��؋\n#lya�P��h������x/�� '�^�֫�bǄ���j�gIde%Eˊ�$�L"��*AjT/!geYN����NdR-)+*!$'�Hf���9%k``�G��m}N\��ꅷ��m�E����������Ɵ?<�wOn����;���x	��%�F���7 V�
�`���j����'�����	M��0����'	�]%���6���K�*�m�_�u7y;��\X��S9�,6k�$�=vYn��L`�h�Ѿ
�=X��pw&nM��n�}��=��u���Kg�j�h;.�u���P�,�õ����0��x�l��#j߽A��/�L9�a���{���!��J���-DG�sEF���:�G϶
�Y�c��ժBEz2��x<�Y���4>��}���OTV~0��ݣhހ��M����6��; E�զ��V�B��K�j�@�{��q���f���mH��R=�5F*�����X֓�sP�)�p��c$�e����5�8����j+W�X�O��`�z�������\	4���Q���=tg�I_6m�&6'	ƛDA'�#���7q���$ڛ��F�ݔ�5�׬�1��V�+]�&�X����;���w>J@f`�ni�绘� �9�֌C�[#�vıǭFT�8��4�Ut[�lK�/���jq��"���_��H*ER�����������,������	�������<��?ã�3�I2M���m<_	��4q��w����m<7O��i��넍�{nṍ���O%����<_�O�m�OC���o��-��>�?������-�Q�/��n��;����y���@s��z���I������G��u����s[���fe�
�k�L��Ψ��P�~��i������9Qt���+�{����bWmN*"(�������(��Ӥ3��:�t�L�YW�T&=�Y�Z�a�<��A�p� �fI�������Ux�����t~n4���~��(������I��럋Eko�x�&z����^�Ѯ����9�e��<>)����a��=�)~�aJwv���<qctjΉW�l�����9XK����V�h<:,��4&1><M�x+-wh"���������ф��������y6���	x�*��{����*��'����
T��3X���� �������4��W����6�]�[���_;���}��%h �?�����JT=����k������
4���r�S�ա*�����+���?��* Wu�U�pU�z�����?�����J� �x`�k��ϭ�������Eh��~hh������O��_^�������?�?�?Xr��ʓ��l����gY��g������}[�D~f���=D�������~"���,���ͬ2��߷������Mgf�̭�YK-��E����%�G3ť����v�����Ty�dI��AϜ�����,�v�8Y��8����\�^z��}��}"?�����d�fJ�%r�h{o�A�],S�9��4��g��b��S��)]+4qV�8�Hϑ3�%tي�shE;J��<+��1���4	��N��GBg�	���؃s�>h�.��\��8��߭h������ ��� 
%�z ��s�F�?��kC��R��F#����'������O���O����� �W���8���� ��s�F���g��O�W�F������h����������}���W�o�	�T�ra��f&�qR�7����_����_l}�N�]�{[�����Ύm)3�8�~N#)ѣ�����F�£ۜ�����;�ذZ�����F.���m��	��3�����lG�a�J�d둿��PЅ���+�;�.��l�W�dj*���������Ʒ��pd�KA�b�[�F�}Z����4�Ζk}�D���b�ba`�I�8^x��1w}b�ˏ[j�l���K��ӱ>�3�?0�C#��@����@��:�dyz��� ���[�5����>O�_���M������`A�� c�9��>����~�����lpA@2�ǰA�FL@�<�c!w�8��������W�_����}W[�c1�m�`�,͸ӡ�ϻ����S�]���>�;җ������D��'_YǴ�+�s�vG\�u�ٲ�����<�t�ْ��X9�"%�e�?Ć�0��;4��N~܎Ϊ7�B��[ф��?�C���@׷V4���W��0�S�����WX���	���W~��;�b5�u�N"6���;Z0g�u��ە��
������>���ј��K������xd�.�EaŁ$�]
[G�(�H����j]�B�.�-ۚl
�Ȃ��TL�P�wi�oE3��5����~���߀&���W}��/����/�����z�?��@#����?��W^�ny��5�QyG�𸙲���+�r�����W������%���e�Um-� ��?q �}x�U��q���J�]�� �yZ�������SR+�-����a�[mT�z��ooW�%�:R�����6�y�������\��U���o���*r��\󁾛D_^�-����J�; L�-�x�1R��U|"��O�Q4��i,�>�������T�3��d�h�.E����Ŗ�ފ�;U�Ǐ��q���7������5L;wm��{e �f3�+��l!��-�2��~L��ՠ/��*���J�E"!�7�ޥ&�^�pEt�\�vO�/�f/4A����G����Lx4U<���؃��[�;�|<������������L�Ƣ*�����[������!���!����'��kB%��=��=��1��ع7ǉ�
0��<�a(>d1��B���� <� �Rl�{��b燡	����/��J�+�݁\��Ρg��k��x,Hg�(���S%c�Tj���_k$��]�/�UR+=ݪ;�ܩU����xS��P��`3��Lp�Dt�3:vu�!��� �۶�ܴa���h���S����O%�x��E<��*�*��{��$��*��g���0�W��o��!㽉 �����	����r�n_���AU�������*�j����H_翍�`;6Z�9*v.锍Se��w��AY���,x/��
a,�����}����[+�����Q�Mh�q�Zt�Wg�;GN;�&�Y�-[��kL�6Y�9#/�����m=���Y�<M���܊cZg]��2gX�����q)�҉
me�b_�r����Y�gۍ�7�s����YQy�0�m��m�0P����ImF��ݥ<�x?�	��H�)Q�f2��D{ߞ��<=����m��J��v�c�$��H�,Zcҍѻ��v��<E-t�=Z�t�w�_$�gOs�	�ˮM�W���քj����T������	�O�$�քj����&��G��$��U����o����o�����8��'� 	���[�5����_*���/�
�4��?��%Y��U �!��!�������o�_������~iݯ�U<���
�%h�v��I��*P�?��c�n �����p�w]���!�f ��������������5���v�������Y��U�*�����*�?@��?��G8~
���]��?*B�l�����[�5�������� �������(�����J ��� ��� ��5�?����?��k�C��64��!�j4��?�� ��@��?@��?����?���Y��] ����_#�����W����+A����+G�?����������W[��B#��@����@��:�dyz��� ���[�5����>p�Cuh���U�X�2�X�ĸǇ��򹀧2$q����x8�z�����{E���>����	�O28��������������^��{u��?9P��ޭ6`���E�/ji����gw �1��Fg�$��-�A9��-q\�C���$e�c�v��.۞Ķ�1�����B���������3��8������G{@����/}�kc�&�e�K_��݋��o�p�C�g}������֊&�����C#��jC������j�~3>!������ï�À��s+�E���vH��/B����Q��_���9�;e�}�v�έ��%JZ6q8,�y�es1]b�q�yj��s[ݣ��(��Q�\�v现�uy8 ���Gy�]�
m��{+�q�����ߊЀ�?����{�o@�`��>������A��_��Ѐu�������������<��u��b/��D:0[kjf�'Ff���v���߳��I;YtE�����c��%�����zghK>��=CY��Ώ�.N!s��Ob��̓����N?�0�(�&Z0����2��23�K܏�UR�����I�^�M�/��-����I���i��.^?1R����NX	:������.E���Ƣ�sx�z�Xn"��c: �AfP���/�����eϾ��e}y!p:�ɘ���������?��x�[���ՄXTG�9�o�����<Z'yk�D��S���]lw4�7����
�$���yx�����xk����!����$��*���������9�q����	�����w%����D7�j,�x�?��F��_	������)��*P�?�zB�G�P��c��}���Z@��U����-I���5�C7Ns����Q�y�?_z�~ׁ+|�W��e�z����i�y����_��+M�����w�����{?^J~�ך�Y(ї�o�_��t1z)]�n��[��Z�|[2�[��/�VU�Zu�E���Y�-i:�@�v��I���i-�l��t��N�2a1!��kZjD(e���^"���@i1���8N:^vȤ䎧���!Źbj��-�T�{��y��vnr}��͔�ׂ,_�~����o�]T��>s92cQY�?��dK4�۲�B|�m3�ЮI�V!q���(�kWe��� ���Ĳ[��GT�6��������tʟ��i�P	A�xj�"5c���:ϰ���]dιYb���Tr�]7���@N��[�{A#�}7��ߊP��c}���|v�]y�_��]�M1��(#��"`)�_x$�3`���^��6�?
M�����W����W���L��n~T��������l������>3��ŜX�b�e��^�|�V��ȕ�Z�������o��w�h���_h���Y�^�A��T��������j�����c@�U�����V����Ԝ;�,���b(�h���]�ϳ���E��@�R�O��[�y_�o���3��[�yC�o���K�o�R�{)�!o���d�[]S,�v�=2�kɻa�^����I���l0՟u[����A��a��:E~v)!��r�i��X��Ʒ��޺�K�yP��|��Ģ�F��,:-i�b���{A��yֶ��DPg�RА�u?!����p��q{�l6c��)K����E�0�G�l�v� Ѯ�U���Ly��Kq.�$l��m��z�z���]i��Ɩ�ί`������E�=hC*���~��E @BRO�o�DKmRwUo���DحbI��=73��N��J�1����NH���.��A� ��ȬJ���fI"�e)*�SY��� ���I9+g	�G��`�%J�Hn!���������~�܂�D�o��W,��D�Z��˛f��
#0��6t�s�|�P|kÊj�<��}\����Rق��^�����	~�����dP�_H��#ٳ��,����/���h��D�?���������!J���O��g�?�A�$xn�G�?(w�?�F��$��������mx��h��p�y��^M�N�n���X���Ӻ��E�8%Q���z��2��h[����l[��p�tؖ����������CW��+l�t��W+�3e0_�J/K�=��dvӉb�_��yۤF%�������eu@�6���V��]q��1�}�q�^�s$��˖�䭬)Ng�q�g;�e�^+xRx���������ø�T[�d��`��1��jҒ^,o��\[������TSu�zK����J�,UW�nI_�WUu�m�Ҹ*���ۛ8�J�[W0!�I�B^�k�����&��t�T.i3�lJ��Tk��N� g�$���b�le�#�o�j$A�����F�"A�_���T ��u�$�?Z�)>D��h"h���|�'G���H�����h�'��������^��� 	���n���G���!b�G���D��g�ߠ����#�����o(����������տ�K��!�����?M �?$������(�gD���Ϧ�#�� �G�?�_����#A\���}�������y6������"~ �G�;���!�G���?������� ����(�����?�^$B��Q�G$�S��������׭������h�GDH��������,�M��� �@�P�����#���Cy!���_��K����ؐ�Gy!bB"������G��� �@�P���!������O$�S�y��������n����/�@�"A2�M��������؀�����h���E"�����������.@�|@����I��y����"B"�_e)����&���h�c'��� �j�D�d �, U�U5M��pC"Gp�`�w��zux$��3�����G���-��[�W���_*�z��	���]�:5:�.���wP(%"�þ�VKg����V��+ۮ8��b����S�����L���uM4j������n��u��VF��������A��V��B�4ۖ+Bg�(�A��>KZBile���tx=+j[����fDީ�����M���	C�?�������&I�����I�4�'>�����@70�Vx�H�#�/>|K�O��UZ�Mj�
p�T�S�;�>5Dn��+}�9��B֘���BQ]�M,��9�.2�� qx��<�-��+�^Ψ�eU�M*�Pd�[�4�,���%O�Y��ӷ�'�Rm�/E2���Ƅ8��*ߨ�ب� $b����(����/��������i���ǰ��/��_x6��^�5��_���n��t[nk��Y*N���_q����}�BQ�HG�	Ot�0~�ن=�m�	�jv{�b�it��ve�;�@V���bS\V�6��P�%��ۥl'%�].�UBnS��\�8�%��Y��q�L�:U�²��uv��>�"f���^�uz��c�]A/���߇)#Ah���s��{-�=H}.v8�V��yS��{(���O���ț��w���t-�l��bm��(�i�\l���n7�d3�����m�����ŵ�N-ۣӍ>��V�j���̷�?��{�$�?�A���������d��"�����qa�G8�����H�s�8��Q 2�?�x��ل������Og�����Q V����n�W����c��B��������E��n������c����4�7$��Q���n�G�F�?� ����?��������_��"A��� +�����_"�����h��X���=��%Q�G$x6�c������]7��)4���^��Cv��g�r7��5(������+�/����c?a_��~`/��ք�)��q��=uo`/��meL�Sn	;�X�V��VRy�	���c��`]��d�� $eTN��96�����B��3�y/�v�E����S�a�ؗ����~�q��R�-L�O�&��J)���8_.�K^�7���ر�/�f;��]����!�ΚÒBv��b�'�.r�l�ťN0J��-f�@Ū�ԚҘ;���kd�,`�s���ہ4��iU��;iw+q���t$B�������{�x�m����׭���h�?6$���?Q/@�H��!����#������_(�W��?��bB���~��U���[�%���LH�_8u |o$��G��c�s�>�������ղ��]�*e���ޭ{?��Q����AP�O����h��E{
S�T v��. �����z��M�*SF5+�e5�rv�2n;�NM�Guj1U�LxiL��v��o���6j�����⦜a��R�ӜD��ُ� `a��� `a��b ��yIT�)#Wp�)��?���Zl����2�^nm��DNi���x�E���U�> M�_�Rs������²)E��z����1���뿠�_� v�w�x�-�:���׭�����B����(���s4��N�XY�sYL2�Bi���B2�FQD6R��#4�Q�± ��	˾����##	�i�O4�?|��?�ܘ똴�UnGc��a���u����o8n7*ڬF~.uZ�s���C*]]�)�q��ug�vW�l>�J3F
G��r}��T�]֤R�]�Y��M�����q0,h�˳��6�i���?_�$���3>�j��E��n�W�$���ŇD�?��b���"����)^%���������s�����f�"�'�O�hy0�V�~��Tk�v���[˓��v�-��u���8y�z���yZ�����)��!��sJ��'ۺ�[en]��FIQi�#�������"�{�pc���^�d����_G#�b���� ������b��B�_(���������A0$A�1L鿘����O��߭�:��Z7�4�"���$��)��x�w������b ��B c R3�[���/e��M�IU���w�󕬨3���:	�S��3�t���-�v�n�Xd�T������:^E)��q��l�(�v�e�<A�r����J�`$�^��>A�ķzE!��O��K�)X��ޫ:�l��{J%[�D%�!���!�2�U^ �r8�-���ԅ/�l<��U�y,�GR�n��^/bO
�Ja&��Jԝ�*r���2�)[�z�v���u��ف�7ַ�-2jw�9��`��`]�����T�c�5��6���`�l�7�����9�������g���!�?��fi�8�sX8�����q{����l�dԍc�>^䅶$���wM�[~��9�c���MXܵ�ښ9�x|s�P���L��W��򅹭����Z?�Q��.Q4d��SQ�`������������O��<~�}ܒ��;�����������k<3�G�T8�G�Is,��)��E���+��VZ�=�~���m�L��qຶ����|~1ٚx7�|���9y���Z� ��b��V���t��OXrɕ�7 ��\��&����-���o�����<��؟x���w��:�^[,�E���
��
�׿p'��_�T�p�7���	$��[?|���� ��puo�s�]��i���Y9��$��@�M��.^�:����\���ྍ�?$x�i�2,�����9�]Y�i��2�{�ܿ�� ��{;]��}וj�F������W�V�b@5l���K�~��9 �G�������x�gX�� .qc�:�П�o>���"�m����;G0��6w�jڸo���\��۴>V%��n���]\�wLl�B�]����T�۳�J��
+/���2�O�p�����սV�����E�����ɯ�����b?��?Eg�����/~�>�ݐ*�@<g�	.sg�I�	T�F�?$���|� �;��ߛ�}���C���&tg��!�x[�� χ��_�Q���`�g&lX��W��.X��a�t/�C=��'w�_���{#gC���]�'���1�~r�&�UMy����Bи@�aO��R���u�����ˣ�x��Ư�����{j>�Yv��s [��]���b�_�-O���Խ�G�{��0������?ށ?C֌���+XXܗ���!�_r������ڝ�w³j���������!oH�`m���T���R�������]�^��D�xj�o"Bx1���&�D�������g�?C���-@���a(��Q�y�?R�w����`Ѫ�,[�8�ړ���Ƅ���e<|I�(��\7$��n��ߟC����sڂ��ai�C����>�������{X�/o�?H���Z>N~�y����`,q��A�!��l?��e�>��B]%�|[��j`��a���<�w��~��K�_x�'�{��Uz^�/x���f�o~9��_�'j&vWȡ�u &a�!���L~sh*�"�Veq�6��/�=�ñn�ԟp�X��O����j�݇a���?�B�������z)'O�f���~_�U��\��_����FZ����YDp�_�fy�_�����]G�=��;T������+���п�e�2<�xRX��;Oϡ�~���*���]}8�*�G���������

�^���#�;���)�>uB����'7v�?���q����#���xC�N���W>ܓ!���#f�U���=ߏ�����x��Y��s}��	`H��e� �h���w-1�$iy�g��6fv�ɞ��T��twuU9�L?�E��;]N�]�2B�tf�N;���L?W��B�]FhAsA{����
���
���������]�ꚮ���l��G����D�_��h(mGcr[�[Q1FCr�b�QI�!: 
T4"�ZTDbM3���>@������v}&� ��g�l�*�e�Fz��C<ّ����pYIVe��~�4����p��;���uT�;}��7P���m��9��}��zV��E��p��9�y��2q�E֫��c����G�>^1%h!Ȗ,kNղ�N�	��_���2:���_�w�+���0u�������{=�ط(���˄:sO\/�'|�sa$7_`���?W���鋩��䟢o����/&@ݜ�\�sY��Mo.{����Br][������y�<���:�����?
���`��9������M�9u���D�+����]���6������;�ß��K[o�l"<�P�"McѶH�ڭ6-Fc�p���� ӔL��X+�E��1�ՊD�`+�0���߿V	,�5�*;�h���@l�W����7H��9\�)��6�& ��_/}�/n߿�L�魍[:[[�^�Ļ��/��~6���|�a@��0�w���L_��y*� -�q�<������y������	?��s�?�O�?�K7��}2�g^qq~3��$}�
J3Ɋ�煴�UV)y��WDY3�G����'١ v��n E��'w^��m�{���C&嶢)��ɮ���H�
�W�l��.ဗɒ��}@�/�8��Tp�w�\S��j �ry ����o���ŭ�P�(Ve�ӡ^��rU��p-�i�&'6���^7��}g_}��ꦥ��q�΋��n{/<�q��ULa������J'o�Z�����W=}��~]C�l�A��Ҧ�ፎ�d�����<E�\�KKS����3}d8�l;=2��%I�!��9A�U���˚�O��Ƕ4�:��( P�H�0��%B�,C�MH;m�"m��6�-�jMt�
Ur����đ䃊|2RYzHֺX���(��1i
���/�A��с��@���U��>ļ e����M�u���$#��\~P�D�/>C.�T�=:�2���;�����w��?y���3�ɓ�3�L�
�c���5a��oǂ:�l�d��#����A	��S�cҐ�!�hcY��^���i���o�:LS���3r��>�5�?�0o0�r3K�.�{�kzU��x0�L���a-�g-K-�xF��ꔋ+�W�_�k�Oq��
�B�1��Q%x�\�_��_	v���3VgA<�OvOK���}��җ����-�T )��>Ҭʝv����B.���&�!���\��c;�ݨB�R�$yJ>���rN3=��v�RM�1�,*�1~��$�J��qء�QǠ������JETG&�"�+�v��ɖnuz�J7� FX���rѶ[��rk��h��F�Dk�CՋ�Iz�yQWUE�W4sjK:���m�	W�ҍ�}�d����@�V2`?L�<�94LO���4�:q�#;wu���Ami�"�J
��~3ɏ�5$	K�Gh��-�+�7we��YD������g�q����C���%ݬ���[�d(�i����_��ꟿg�U�o���s�o�듟��'�����B�>��w)0��q���;?�{����k|�D�}H�Cѐ$�I�pD��@������L8Т�C�� #3Q�
������[�&���_�ɧ���|�я�����d:)~����������
��6xu��f�6��m���񃷜��ｵ����|�D��=��{�?�_v¡����e��r/�`��SN�Z�n4Z߶�\,+3f�>�'W �z�9_6' ac�dR��a}���"�����`�ͱ8`�ǵT���mȜ)_��#.՜����
��<���]�˗[���W�U,A���.�`���/��,��2p8��N\�?IO8�i�_�����A��C��ϸ潹��9�_R��x2����� 7���Iw/�g���5���jn�\=9TMU��t1WnT�������¸J�L�r�RÌLW(��t`�{s3��b���=΀x}a]�Ě��>aNΜڠ;t��;�RO"f��Z�Q�=N��c&]���ܑ>�k�vwxB?�}�����S�=+~,�:�����̷�|=llw�t���� ?�$�̑*֙�0nT�V��hQv<l�kũ�7��\K�r���ս3`n�~�\i� i}�R�QQ;,lϤ�xf�E=�W˧@��������#T*��͚su��9�&Y����R�B�k3N�]����I���(ָ`��pZ�M�^��4�ep5�O1��x��ɤ��%4v��Ǜ�,Hw6����(z0���LZ��z~))��c��]Ш�r��7#j��>؃� U��#�Hs8IF�g�R�nҩY�39��j�<���1@m�(4��N��]�P�:��X�G�R07)�����FSE�\<�J�?9�UY�b�$�a^	�,-#�սfa��@��S�WN��A9��I�v,�Qac����܎$9F�j���06NH{�Se�����IzZO�7�c�Q�ْPf	:K�z�=�)�:x��e���?��ù�REo_��=��ըJ,ޛS�B�P+	mv��?����S�� l�=��� Ŗ=�����c���b�3`õ5]D��6?��?G���i�J&����`~�IB�i6ju�7S�iN�5���Ԓ�f�?ʱ�	(.L��ݬLT)V:2��>��B�)��7?��?�c~"M�mo'�@��*��GŠ��٢���J�H\x�ONa?{�'�f�t�H�Q*�Ԁf:̤h���IZ;ntbʌ	Y�(��{����Z���r*S<8T��f�h�% �I��o��q4<H�!eށ�w������w���{{��W����y�ދ�pύ/V�;!���Pc��8,�"Έ��6^&6\�7��s��9�5{�g���^�	b��
q�x�c�Yň?xq����C���w�E����?v���#~p���{��(���Ue�96����b�T�xcVHE*Ga�-���B�z�$�I��4N"�4��x��\ೀH"�. "~���.� ⮇. ^)V5[�ϩt62
'¹��$�{e����@��Bq�Z��me(5���f��,���Ě6i֌��A:�Q�a�ᇃ�����`���J�J���(l���NnG"���O��Β���m��q��� �r$����L��u��!��G�T�D'�����_�� :!�UT���lS{ݸ&wiU�n��|����=����1�"��Y���o�+4	�(�<G�|�����̏��T4_4;�ne~��_����qε��U9=g]99(t]�<���G�Z*�'�g�^jVH�gU�i�����&��T�wpYyw�`��;�A�/�o5�Q9s1�K�y.4�I��4�%k��R�<Θ�Qᰙ,kZU.�����\ʍy���A�����2h�(��:)s%V�*�^�Y`���B�O�kL��" U�GR]��LyF�K4�Ig���mGݓ������'�a'�ɝ��MV!�J�벼0:��%9�<�s�F�V���\52΁x��M�I�Oe��J
L'Y���l��Od.aۢ6�X�j�K�s*�%ʌ��˿�\>�_�+7o��y#��)�t}C����n���׉����W(���/Z��.�����9�hE6-C�Oň7��/����\Y3Gfm6����������e|%.Xb���e�-��p��ӧԻO��^�o��p��}ەx�x�.";�70
���*�C�Y�@/MznT��OY��*Z�U;:$� �8*�k��nGR��@q��u��7����+I�l��I0�&x�Yp��\�|.��^���<�������y��_��s��+�4��ܜ�]�s5������$���η2���2�P��F��y8�%�2F���.̌��a��D�I��`�C�����:��>�qK�UT�n��"s '�i^�{�O�q���|�[��#痤Ua.eX�;X.K�~|����~��.9}�z��95z�:��+���k��_S���wdM��~�t�@F�jRW퐠�e>�9^�G��EN �7���ÂJ*X4-�hG��"L�{CƅD(6δ��&�*zS}��ݸ@�g�߼�		=Fr�1op����9!I�"ͮ>R%R���B�B�]=K�4���5�\�����/��pl�k0|�p���!�_#�Ig���E���s8h�F�{�m��C���W�l��eU� `Y+����^���}Ĝ��D�5b��}!~�b�sI���'�&ÍmŪ�F�
V�i�s���*Y�;1��>��/��C?CЁEщm$#�2μ�E��S�7,�&*CA�'+:�ȧ�x��ڡ��É�˥3�s:��7�zD����3ibW7е�{����(  $76c.��*��/(�$�n�h���������>PD��������Ѻ��΀;�n$�ws}����H8䩵D͎ �@���)�(��D]��I%j\���t��q���E(�h��H>	�c��b���-wִΕ,CVqd���kc{J�"�L�c(�dm.�a�.�(]FR*��/��68�Ճ<@hev �ڗ��1�[}���S�
��Ů�[r/$a��Ip�Ż���a�+P�'V:0�_?ђۺ��L�@�PYLǿ�O�e�h#�Y�e誹|=�,c�hLK���<�ƒE�$o������2�U �ec ���g}�c�&Ljnr�_ۂ�<��U�Y����r�O��B�>���*�z�P6KZ��`lw��*`�Nű(���ܕ���.���7�~x�����L:o	���ո[��"�ߩG�É
��Go���v�Ex�]tC��G����j�z��0I�M�yȖ����X>aup�L�B���G��$W��`c�n-�&n]+j�
Fv��ĂM῜�F.�:��h��4��4%gAi)�&�Pp���w]qp|M�&��w�Ʋ����ٱ�1��p^�9���׭�j��m���_�������Ƹ:��s��3�������?s��w-���O~�  4��J���ں���?:*�[�,�[�/d?�����weM�jK��_q�{����Ӊ�ˤR*8�T0����h�5H�]@w�z���P��Y;3w���K�>�nn&��R̖bƿ��#�����׀������%_O��	[M�A,���O�|6��ֈ��X��,\�����]	��>��3���}���ж�8�a�g{8�S.f�m3��,�1�Oڎ�8k��q�O�>n3���Tv��{������w�������v�x���k����j��N���\4��P&ɉ�O8�������s�jʊy��%�PL�r[��*JK���|g<�j5C�eS��������=:��R-]i����S���C�j%ၺ������%	ݪ���1�׎�������S�!��x<�)�^�@�5��`�\4��4������{QmHx�c?��L%L���������4@���ф�߀�>�Cǳ'G��������/�����y��^R�ҩ�ޓ	��TTC���G��Y��Ǉ��[ŐkU�h��̆�Q���ѭ�BW�ٝ��#|8O��g拡���^��g��)�����UI;��\��.����hWMM?^����t�����I=B�h��A�� ����~�t|�ՈŚO?e�!������~����R�)�e����w�A�v!4�Q��A�%j�k]�_����;������G<H�:�I"�����$�����������D�'[2<���$�L/�?�>����o�w��P��v7%bR�̎���i�~4	#���ɘ@K�x�4+�S=��߄N�8�r{H��'��ޤ���K�Â�g���_���9�=�$F������}`�I���T�����2����E�O�A��4�O��p�x40g���W���<�e�W�����^������$t���|���?���z��	��4K���������m����wEZ�������#����`�7�(Ѐ�oU����~ra��}���?�� 5���x���}���,��G�p�s�$�����,��>�a\�tI�%��|�|�"l�6��������d�k��S�����?�ҽ���(�Kb�b	���6�׃�_�g��l>i���)��%Z�{k\�M��uC��km{`
�8��Q]2}Sq�)�W��-=k�>QYOz�a�kZ�kGx�o����ݝ;���u�����L�R��x۱�3i�@'���|uQY��!�?���C
����B�Hc�?����T��'���?��R��g����������?!�������?�F��|g ��g��O�����<����8N�(Q� ��Ϝ�i���g���@���$$�_�Mi��K���\�?��i ZuB�Nh��G�p~
������/���<���V ��{����*��?%���>4}�������O��?����c�ߟ����o��㚅��/�t8jF�u��!��OW���F\��|��3~����k?��O�c��QT:wf�e����K�'2�8�en<�A�ًS���4Tz�:j,��P�kc�6��$��k�X����ra� �C�hl-|m���d������K�'�ϒ��,�P	��Z�4����"�:�)f[W;�}�;��%�lݧ�_��Is����kd�s�PV�̪,()�\�{�*�@RK��ۤ{۶�kS(�8a�p�Fu��4u�7��׹Vh�[� ���g�<��Qd����������̐3������?A�����O���O���O���'�$�i �_8 �?#������\�?�\�?���������uȃ�����������w���Ǝhl��Z�3���'�Ӝ7����b�����~��[�ڭ�.=��#����j��-(]�ة��o�Mi�Kg]_�S�B�.r�B�0jo�GSV+DTE� ¥/s�e����jW\9̵J3�1]	On=�د�]�N~�r�	�tA���K?�z�΅G���e������ͺ:4jH���<�؎n�1��?��z�]�)hI�J�%�jcG2�fϣ�(���I=�UP#dz*/�{4?o魩ѭ���������� �/�����p=_�����������'��G��O�����ۧq��ܣ9ڡ8�y��1�r8�u]�uI���%H��H�qi�'�ǠG����O���?�N���P�i��P���"j0H8�����S�/�ۨ<*�e���;��:�y�lK����6-��+Zs/-6��(!�A��wv��֝��)9ን�0P��ܬ԰�ޟ{�蠴��̝j{e��+����gv�z�_O`�7K�a��/;��!�'3���'�qt���y��������6F]il4����6��M��3g���Jqg�^o�Җ�7�O��LUiIA����~aܔl��~d]I��(l`f��v.7[Va?��rShX�i�D�[k��(���h��ފ|��$�3B�����ƛ� �_P����꿠�� ��_���3@.쿣�����h����k�_�p���^��P�$��f�a+;W�ʮ{���2��?�E��83C�hm>� 9��� �C{6���TuK��;-U$n�j ����)��	h�����a>#�ظ��#�B��H�g#˒͒tp�B`��
�u�+��qc;�J�E|�h��W#�XϦ���FHЫ'�w���b����Jq�z�(F�x�Vb�ţ��74��PF����mK�?�W7�x�"��qF�JZ�Р�Z�K���^�bA*��I��F�CMH��9p�i�t�.�JKô�fQD9ossp�B�����ۗ���3��E-�Q�"őϣ�5�6����t����z���(؉����ƍ���.4ȃ��S	������׆��"��m�K���)��Hy�K�����T����_^���W����T �������������!��m��m�q0��X��p§\��m�f��Y�c8��/��I��8ާX�ۇ�ίB����_�/����^�ٌ�Iw��^�@�C�Z������u`���i�.��2e����޲�H���R�,�ܶ��lJ���p�:U�P�괽o1�Ф&bO�3榬7�_i�$���*FN����V�a����?���
R��X�!��<�4��#������3W���K	)��M���C ��g��q��?%���B��a;8H��߭���S�������+����e�*���;�+�I�*��=d��-�%�[!�����5�3���V6�b�w��msm�i!y�Z�!��~�6���xi��zk^ٲFg���#z���m6n��2n�؉��wmMЊ�g������"�9�b�P�j&ӣ�})��Q�!Vt�*!�^�|�z�Ƕ�oH�����aEU䑕YG�t��Z�����
���>$n�2eۛ��@Е���%*��")��it}��<�����W`e���Y����䡁X��̧��ޛ���V�H�ٍ�tZz�fcýD���3�����Ԑ�����_FH�����9�������8��R�H����'����i �!��!������B�o=	!�G������<�?��g�����+Dr�\��I��P��
@��A�����J�����K)���0�Ԭ/��4��#�?	�*��XB�w
�?����i��,d������g����!��?����d.����Oy���������?����?RA���!RFZ��^�
�R�?���?��)�B.�?<!��� �T�d����������?��SB���B�G��$�
�R�?���?��������������m���a�?3��A"e���O��@�!���?���?d���`���c*ȃ�H����o�/�O3��� ���|�?����<����� ���!���v�?�\�x��G����`���}���|p����������D��#����\�?��A�Y��c.ˑ��x��R��A�$N3�gc.Ia��s��;8kۼMQ4{~��k��'��������j����)݋�_*=N�%T,a���� �ԨR���c�AzU��Yx�7J��d;)ʾ{0����L���\m���4̅����-j*M���5n��&����n��DiH���9�oU�'lW@��f_��̟��>��ҽkwuQY��!�?�f�����v}�D����C.��2C��|�G70������/;�N���:�+����X�id]��}�<�y�t|g���{a���;�����ƚ���j5P��d#����������%��nDge���bW���.ת$�@�#5u#/g��@���ފ|��W��!������w�7��? y������ �_P��_P����2����ra�aDb�쿯�k�_���W�e��7�)��3�:�p��Ġ~����b�����m�v��{%|ጓ�@�-��\�-��1�d(��]8V�)ē�e{��C�5-m��*A��̐jk�h#f$k~�'C��+���Ym�F���rm۵��;k���N����͢��q.��@)��o'�y�X�J�B��o��-Qv8��^���a���*iUC�jj�u��+�J]R���i.yY�	��tr�y��F�-d���z}k���ʸ�	CQ5;����=Wq/O���y�(w肿Y�c�?[������,��W��z�<9���q,���߯Ǘ�������a�SA����������I�R��4���ϒ���G����A�9���g]O�������?ث�K�K�����$	��^�C7���b���Ŋ7�I�j.r�߭�Q���!O7K�Q�q��u�+� �����S��hߏK�����#%����OC��.�Х�.��e�Z�<�-i7���w�VU�����	u�͌�7[�&-
!3�j
R��I{��+����
�6�m{uK�Ph,p{"�V�@iq]���]���h����隚[N�lNM�*6\q�[�2�l
���v��~A��I4���9@�|OU�������.�x���b�=ѻ��';ܠt21��-}v坽o��:�릷5a���}fx�u�A�G�"�	w��3��-�a9���m��*[���:��D��=�T����:Bk�4G_x��n��Y�qX�n;C�E-\&��C��d�,F�lV?����.F�fX�$�uư�&��٩��tX�+'d!�<�G��>�{��~^�����M����	9�?J#�Dk�F�4�cjݬ騚.�I�n"xj���Sx�n�5J#uBG�����K���J(��'�����G���e2�E�����j$,��|����jg�������k<���ʕ�jz�\��
��.^��O���?���\P��R�����\���<�E^��M�y��;������=�_�����O�?)���Q�}vz�
�`F.M���������I�1�NH���/s�A/���?��A������g��fv|����~���z��O�9񰩰'�Ѥv$G�U>�����>>ݷ�u��<D��ͪ�!��Ӳu��<�У@L��g"ڜ�f^C�)�'��z���������TM8y���ÌM��M���f�H����Í=e���Ĵ��~?ƙ�u&j��{�EFƌ�׳^j�X��J�ǉ�ҽv�� �(l��a�Q]���TZ�8�Kw�G���?���2�?�6���	y���J�n�4�"5�ưl�O'�Oe��*��*�5��Sa��QS1�H��t����2��w�@����k4I/Q�� ��?�uan���D!�'=]`���M����uْ�襲����2���x;��`�����Y��O�������O�@�G.(��7�������#�W���ᵌ ���h����C��)��˂������m�F�_���/���>�U�2,IcO���m�n�"kgn�?��˸�J��/�/��6N����������
�q���g�H�u�����]~}캛t�tY�\�LVB�:s�t��:s�[׮����u�qc�Mݝ">������I��V�8r��~��T���cs1����������z�(����k��Aۈ��[�Q�T���g|��Vkx�e��|��v��N	?��0ɥ��p���u&i]�}W,�$҆��ޡCl,��KV�y�[���RS{۲8��[Ǝ����D�sS�o��p�H6�Qw-}F�q11��t=/AR{bk��x�v����`�8�ŏpZl��k:�@1���X�mt-#(��8�����g.��Q��>� �� ��t�%��߶�+���o�!W���C)����o
�� ����o�����{5�w�\ e��߶�+�����7��B��B)��;�k`�?�����#���?��@������W�i|y�����	��<P
��n�?���9!'��	�#B9 ����'���\P���� ���E�������?rA���B������N�'�(���� /����p��@�P��x�(��C��A�G.(T����������J���;�@�G.(�����P
��^����� �� �?�������/w��B`��m�W
�����,��B�R����?���\ �?������P�������
��c���b�����J����� �+���A�A(�������� ��������OA(T���coB�����o[����k�����r�Nb(j M-	U��E.5���n�K�F�A���n�Z]M�����F"$�!z�g�gG��F��� �?<���i��E��0���b����vD������_��ω�dE$Q3߀�X$y���^;��96��J�F�Us�V0��=��p��ɦ�G��u1�(��U��n�t/,������r�RƑ=LT���֙*}�!�$��¯��`0͙G������'{�椊��%C�P��86��.��-�0���8���A�Oq(��/�����E_�7�2�?���Ï��X��`�1�cSx�"PB��I]7�iҵ,w��]�X����j���ɺ���FkO��� �6<��<�wP��d����~���͚o[�x)�l�Xcq�ܮ䩯.��Zp���Su���(������[
�u�Aƫ��A)�@�Wa �_ ����/����(�Ѐš�� o�	�_�n�����}����� �6���NQ`���������O�ȳv!���f�Ё��Kg���� �v6��B �.���n7SU�,{�?�R4��ՙ�L�[*B�%t�n�z*�6���u�m;��j���x:j�>!�V�n;~Qg�p��V6��,�Zn8.��
YKh��Ο��9�*�fv�y�G�$)IE_]��d�q�gj���z���T�5G`P�t�:��GQE���Y�T�Wm��y��I�vy�ӱ�AR�>V�(	���(�v�1�&�&�$��tQ{̓��?��{�2�?� ���«����`�r"�����?�N�
�?rA)�����B��y ?����
���E�?����"��b�?K+�
�m ��_8��w���'��O��}1�  ��/�������\P*�U sG^��G�?� �7�����#���vQ
��������\P�� ���߶�+�����<��?�R���m�/��������S�����(r�>;=vj0#��~�������Г�����܏,�zY��������gr?������;�����y�W����_���æ�F�ڑ)W��o4V
T'��t�Z�=���I�7����N��I��4C�1���hsz�y�r�@�di��K�~�i�Н�_UN��2��0cS�r�*EŪ��2�u8���pcOi�>1-�~�/�̌�?5td�=o�"#cF��Y��Bh�y�q�C�t���H��&
۬oظkT{�=�V2�R���Q����q�B�����P��{���������J��`��0����� O����S����������_�����)��OM���o������O���B�������(����������������M�i����Ez"w�Qg6�������OѺ�'�{���79^��� =��c �������}��bv��xU�Ij#ˋA�v$u�ż�FՆFCR���(������&6��C�F&�-7�Wu	iOȯ� @Y�����$�o� &0�5m�U�.��J̞�WK�I_��[jaU���~w��5��X"�{]q8����:�W��J��$��$��9C�n���Ooƿ���M�0������})�$�����_�����D@��\P"���8��5�4IUW�j,k���������a]7T7�BL���"�:MaK���������'���?���ZPC�i�=_�	���i�vUt5��bГ�uØ�����z��0����z�B�X���;k����&�����v���L�h��N�;Q8-�Mx���25��}d��3���(����b���	T�W�m��?���C)��������	`j}-�"�����+?���;wj�Z_�Yx�@<�������n;nt1el����j��C�Hlǣ-���;wa.Aۭ)�q(L�R�PZ��c�?�j�0���'j:�S� (8z�����c��{.�1�����<P�����pq(E���* ����/���?@�����A�D迂�=�7����}�m[ȩ��0VEV�x�E����{�����e9 е����ڊv�+��VU�*�PAU6��;<�;U��vØԻh*�����M�G����zr�>6O��n�A$kM�^T���8v}�\�A��cU&i*�:�=���J�,���L��#�Q�6�p_�@����㇭q+�iяǚL���gnjq4cHB��,�@����K�b#�҇f��ɮ������n�I/B_d14f5a�nr����Q�������1st�űk��M"Y�}����֑^��6�G�{�5�d[k5����Z�ב��`���oo�x��w��5f���?���.��e�����Qy�8�����X�pT��Q�&�+�H��!~�3�毿��<t�.>d�{��q�
����.JAL&r����.v1�n�u�����޺�в��#g��o��]q��������N����\?K|��qI9_�WƳ���5��U���~�;�(I~��a	��r������Ȇ��U��W6~�t�(�a�	�Y	BǏ+��fo����������ا�������k�d�v�1���v��t��'۳�Z%����C#���	ӭ7�����~�GE_V���/���7�6?{�'�/����������^	�e�)�+t��o�~��m�.?�K�we��HF �u��������<=7�Z�������ev���^WsV���]cia��6U�M��r��9����ߘ�KU;%�p���oUܔ����'�vF�sB�����H������j�����4#����M���m�;��|umzt����Gʼ�sz�^	#D6��>��ϋ��W��.�o*w���I	�Kb�.7l�:l�x�ud�G�������!�W��I<|v�����}A|��\�ې�� wsY��.�H�Һ��_�6x��������?��s�� ����Fd5
F�(�`�� �x��  