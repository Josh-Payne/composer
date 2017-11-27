ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.3
docker tag hyperledger/composer-playground:0.15.3 hyperledger/composer-playground:latest

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
� �vZ �=�r��r�=��)'�T��d�fa��^�$ �(��o-�o�%��;�$D�q!E):�O8U���F�!���@^33 I��Dɔh{ͮ�H����\��{�PM����b�;��B���j����pb1�|F�����G|T�8� Eq|,ʉ� wO����@�G���}=ެ�/�Ȳ5��k�����j
�7 NX��;�e8P3��ހm�9̥�Z6pZ��A����"�������rl�$ !���mp���c �gZ-���:tu�CDg����s���e>u_~�P�5KSB*�������:����ҵ�a(��8���cu�{�d
|��?e�-��Y�����A�_�~�yA��/DyI�s����/��"����fDj�n2��Z
��S���C�,�k����\�y_ޯ�R�7ܻK<c��?�NO��"�u��e���(�"�D��p~R�礥�/���u��W,t��%�m�Hak`>%pg��K�\�K���a��w����|��6�{���������X�'���(,� ,�qv�W'�N��M"��p�KU��XZ��sv��A(�48& =뀝Ѧ�LJ������5!�촑�`��v@ǵȞ�_o�Һx)���E4�B8_sL��S/�~��͡�p�k�$��8{3�9M�V�vd��c��&�q�KZt��iц��Kx�隂��-c�i��漬��LK�q���@�.k����&ԌA�m�.�P�0�R�:�5��j����ԺȦw���G]�{�5B����;�:�P��h(@�`J��a~�I5�5/��~�Yx|���DΠ.�sH���re���Y���t`^p��'��I���Ǘ����'�Xy��
QB�iB�4]�P���f�D,�04�1:��a!�1;O�1s�o�>U��><c�:xC��[�?l��^��Hi������W{���� �'l�pu�x5P>)e���ʅ��a�v���K����oS��� �I�����4��FOIl m�C�İ�<�g#�}���m6�^�����=Y��F{2h;0��<5L�b�����92X��>U����2�O;$п>�0}3�C�%��+�ZbrEWsh!»j�}��;��a��-�@G�F�F:R�kjJ�Բ/�x_���tr��l����@��s�T�>c|B}h6���_���3ᝨ�*W)���dϨ8� ����֋#ĉ���^׼�Z����Й���Ȇ
��Z.�_+LY��D���_w���I��r�_,��n�"�����:f�?/
�I���?��NJ��a<���t�{4S,=b�Y��2��ݶ`ͳ�\�"���Əi��t���ڄ�����˩R�+VM�/Ʊ���]�w�V/ȗk�%j+�α�����\��a�T����]��f��C �\�F�:��m�M*h��.�b�3��l�~6�mt=ML�xk��Y�Y�\�\�K���\>�_�\���4�y	<�,�~v�	c��x�k1-����7\(����I�� ޼�S+��3X�x�=j[^��&(`K�mאł�?
/�U
xR��Ɍ�Nv��߭x���w�F|�o�E��i�Q��Y�~Ekص�O��2ɞ�<��,�O�]��!�bK�� ���z�T~���&�:�����
����e�A��R����]�7�,|E��0����s��,���ܤ��
K�_ܿ�3O>��{bt�@3���:��v�kg`��c�C��}�u�S��`���������2���a��Sg�Y0K�Ɵ��XT$�����_�v��0k���G'��h4�\��↛v�-�ȲLkt,�p��v�f�B]��#��u�x�͵#�R;[��t���y�(���D�l��:���ҾzvIv�H�ݷ�$�sO+��E6��*���nE�P}"�\���13�B&,~g���@�I9�yb�AȪ�?G�à$�
�bl
Q��F{�B*�U�v�@E4�H1UƎ�1B�8x�̙h���c�k�}�k3�P��f,M���V��s)d��'㿣Q�[��E�����W�5��\?DāO�B>:嬂xz-�H�`�?�;Y�t�a.,��W���dt�R���o{G�LWi���"7��m��K!3�����'
���[̖_����-~�����xC/��3k
�a�@rn�G���d�X$�gM�����r�8�f�B�`�B�0X��T��
?��3�(�r�{�9�[�W� �r��M�ꯃ�p�:5��������A�h�߽F䆇`�;QVS��Hȁ��k�;V�^m�3Z��1C"��Trnք]4N��t�٘$��5hc�5&���>��Y�V��^>`�~�d���%�8�1SBo�0~���ށw��>�?����Q8=�/�� x��lF"Ԣn����$����OC�$�}�n�d�]q���i5�0:�펎���^���R1ƌH?�����H��{����.��
D�!�x�Z��2D�����~>s9�9t(��Ў��|���ɥI�>�|�`8>Z���s��\2x�栔;�+�����+�^<��$M]kDH�a����!��Lvsĵ�BDW�_�db�"��6io��Ek��juN�oD���F����$D!�Ȧ҆
9%*r
�7�0Q��&�(J��v�IeJ��pmk���uH!��6
)A��+@2�p	��
��N�v���t�O)M�y�S` ԙ.� �h��Bf�>��C-�<�$�
b[ �M1�w��FZ�_a��gZ��/�*���KOW=~ ɴK=^)%��`]��j����1a�l?����<A���?I���)�������b6�m��M��	�?�b�1{�W��)Dp>cq7��もf���Mʿ�������x�w���4}r?\1;}��4 ��Q>�~�/CZ0��v�K�k�2Jg� ��kF<��AӀߴkj��@`��]�]�}j�k�%����K,����!c}��+ן#�֛�����t� ;0_S|�on��4�G�q��o����2�g!p��)1O=���Yu����/��<����2�{!��߷�{��w�~�����?����������_P��)�($6�
��b�kuQ�H$b�ZB�8D"�Ę��%��ń�H���$�6$i�?�e��-3IxE^����NG';��YaV�c��,o+��_e��iئ�hn{�+�ȬV�Q������_�'���|�͈�2��[:��?���w�[a�����}�8sda�ղW�i�1F��aB��H�i �O���ގ�O=��]���{�:����R�/>r��;���c�����(�cK����},v8��:q54�=�2u�(rʰ��:�4�=��Ź���:�=ZFx~8����K�>4�������(���*�!�6p���$3۹ ��l.%W24�����Rۧ����r/����\p�����In���q�̴�b/�8��'��S.�q{�yfS�[�2_�$����a�,s.����!&UI�
�ڶޮE_��(s�=��^�RI�<-���P�Y�X�Ϗ�������0+��D��<㞼n6k���IY:�	��NZ�N��
ͷ�^{*fo����W8�	�J�ۯ�#�vJӸA�[��4Y��^�x�>,�3�W���L%�;��.������N�J[�W2G�d�k�Y��֨
Y7�9�I��u�v���Ő{���QɁG����ȗ%mge�L�k��J��d2����.�ń��l�R��^fG�rrr���=K���Y��?4����k�x��Trbi�G�ʫ䎱�::��j��ʻY��5M��O�'�^z�P���zP�����v��{Z�$���s��{�d�W$c��H�y��;�|R�od�SYΧl�*5�+��]9�l['Ѝ's��[�*��z���6���߷�T6�ׄW���n^6�-�#������TS�bJ�w���F*��P�#q�'��D�i�<��s*G��a��R#�\�,���v�U_5�f�3�^>w�o�ׇ���i����w�B�$o�5���SĀ���G_�L�����1�O���O��Kc� ��1����g��2M�&�Y�_(|��?���G;~�/aA�?���N��Dy~���I~������L>����d��5:��� ������z{{�]S�$�V-��9ٗ�2���t��g�H9/��mb�+%�%�����B����γ0~~(�S������U�KR_��H���Z#�<2���V�$@E���n/�S�P%�M3�z�W���Խ�����_���3�!��(L>�A"!!K�_ ��'1�I̼^3�����#1�H̼3�����1�G̼�3�s�L�k]�/<��.�y��U�OZ���O����O��%<�<�?a���|��B ��U�{�T��˶z���oץ����K�E%]l��Y�l�
+�W�����y��с��c��Ϟd�R���k�0[J4MS6;���^��1��!��=[�q���Ѩ�`Znlm�I�>u��v�#�?p+&܇�xK���]��-E��X<)�ӷh\|.�ǿ�NȺJ$�%D�f��(����О�ڛ�w�Wא�	F��x1t����^�հYiT��F̚u�;���ЀrUҏZ���^�'K~�K��8��W� �C�@_�=���ن��	�4���&�r)t��+W�A�f���UC�^0�@�PVF/#�1m�{��?w�"�{�YL"�d
8y����t�6���;������Wrɂܣp��Q��7� �t��A�Ļi��"���:蛮���jע�*@� zS���zРS&O[� �}�A�4z|:���@� в`�TH1_��!���5`��'u���>Fuz&�K�����dB� xZB\��@�I�����"(�������z8@'���4���t���?����+���#wۇ=hb���TzEHpH�T�/�']�Y�FG'�9�c7{q4��2�y3�򒽑��n��ֆ��}ۅ��H�K�!m�&I��!��u`!�C&Z����M퀶���i�4����,N��·ה��c\!N�� 6F�=�*D���l1]�����޳�8�d53;Mΰ;�w>4�bz�om�3ә���f:�v����\6�R���r��r����A�!��H���� n �!�����
����!n�""?N�\���i*FS]���~��=���%Y�����9�P�����Y��/�&! i��s
���G��T����z�b.}����Ӳ��1Լ�:��Z8d<9k6v�u�~�5]�^z��a�$��*}�ϵ�W�"_�Um��	����3$�������ə�ρ"��5���	V,@�!oDn�<f'�͜��Tsf*�"�`-.[����t/�l]����C���_���w9���-	̡�u��b���܋��6x\�[�}�[	�n8��q:�X��n5������\��?%|4�9rj�(��M��砵��P��%E����1�ƒ�"
;���nMo�Gh�[t�&���?tm$��1�������ķ��)��{�q+	{� �,|��ɟg��7�����N�:��2��F��������O�[O�5�C���~@`K�7����^���V�U�u��4ԏ�G�����I�D%�t*���Ҳ�$�Z�N�2AeiJɒ�FgT�$龔ɒj�B�r�A�����?|6�����4�ɯ���?[��O�?��I��p��x�w��?����~Ea����������"��o�~���w�x�_�����Z����>��������ͱ�����ux���k�:W���L��瘥lQ�퓶�r��맃�I�V�s�	��W��u�c,rw�Yū<��yEd-�~y!��$?�vd���/*+�O��N�'=	�-��z���Eq�[1%�r��b�Ö�]������YLz��R���u��V�]��@�qi �*������ͻ���`���EytHu;�+ڳ.�uĆ�tT���E�ۤw��A56��D��r����V�%;R˧�D9a�=�q[�݉}@���@hs�65��WK�N��7���*��̛ĩ;�
�v
�R�/�q���l�5�^L�X{�0��/���nc����\T��n��[_1t�^�xA���1O�6�I����S�t��J�;��Լ.Y�rw<�&�Զ��  ���ӓ��>qخ�뢃-��^��vj��O���*\wuP��9�pd*m:%�;Ͷ�`
�3�ȩVu���Dk�X�/f�f₻�p)5����|��Jدc/7�{��S���P�;{����G-��eOVD�R��f#7^�;�"v��;ja� ��<���b�{mуA�s=ѓq���~������ȟ�AUK��x��.͒�,���J�1ҽN���,�y^���"9Te��I���nt��oKT��j�v4%Hk�ZR���.?X �E��{���1Y
��l���WGU�6�bUbNV.��U!�&�S�\�Sf�s*[%��Ϧ4bD�:�Vm�͹�q��g�%�tJ��樜f�Y)I�/T�T�׮N���}N����h�I���,|������{/�ފ݋��}��^��w}�/���_�^�F�n�j5������}���&z
�LCY�ޏ�v�k�{A�����%�����9w,v����K���W-��o�ޢ��ފ��7��%W��|�����c?�����w������
�2UZ�|��̫-�`klgY�Ӎ���W��|���e~�c���ϑ�t��y��p�KC�G����,�p.�:Zs�sa못��.����G"�8p2ߨ��A��bZ����B`ׂCdY��ד��,���/�g�\���MjZ���eS5�3?P�#�R��-�#��3J�ɍdM�'�Y�(���;��Q��¤th;j1U��d��GbY����z���3S��l��̴�sTN�l��d~52X&�L�_���ӎT�NZ,�n�i:����lCP�"ñ<c0Ƒ�֎
2��G�CoiGijxT���r�n��mW����r՜�v���;�������rG8)Q	E�fb�҃�E���ߺ�hrPQ�CE��-%�=���r�ϔ��>4Vg�������
��/o+��s(�ܨ2�#RKq->)r�e�_V��bZ O��0�=<���cץ���1��0]�{@���9��&±�rUJ�NT�6:��3�%�V��݂ݚU{\}<nj�rbo�1���Y��������ƨ�%���.Ԙq�ȝ�
�jvO+��w�p��S�yOQΉ�x�r���`1zg�iK��(A�s����ҝ���Ӊ���l�T8�s��xFT7�F]0�4;P�25��;�J�ΰ�V'|����06�ܑt����h�ѹ�)�a�h|��+������p'[�:meJ���g҉��R���� Y��X���񑑞�D�-�))��J\��]Ab��$�|�?��u�`Ă��	v�#�@�`k=�Ba"��X LP�
��^.P��q��>Tr�=;e6k<V��Έ�N�>��9��w�̼Wo
:ɯ�ZB2�l�[IЬS&*)�ݶ�������Y�P�\W�`�D�!P��r�u��c��+iD��u�4O��މF.n�%J,��8o(PXrP6��Щ]�3�V;L��e5f>�(��5�j�&k��6]|&�dWdS���{|���e��S:�f�3��E��ɵ^�A��@|�K�{-�����Po�z��Ze�r�P�쾯�64ۙޭX�^P���b?Os��=�[ˉ{=�
��m�VX�!�s��(����bo�^������S���O�a�oc��2-�Q^�뱗��ȵg���o���P2��!�y� ]ћХ^��yz{�(�c�3�n@�T�1�e��|��"'9�_���8gS4u���o���uqU�j���1:� {۷}�^�#����E��Y�����w�>O����'rW3�E��?<�<���"�����H7c���;�9���q����ף8g���;�a�x9�����5O�@ax�l�:LE�$;>���Hs��p�D�a��A<˄�>�q�#��1�7lB���؂w������uL���~�#��YU�6BWl֍�y�h}�~�\�nV9{�z�%-�����!HO�������v�b�;�&����:zSH��L��7��x+j	����!�G��%3�;Ƃ���� �)B� �O5TI� -z��bt�쁩�M���4v�H� �±I�8��3��x�"���x\p�����j|���|x�~u�͗<s��� ���Րm�Z�F,�<�xoI���'�]����s��Ootx�6|���c��5Ӛ #`m<7����ٰ߇��@8Ⱥ`�F�b��OZc��� @�(�'gL�VĚ����C�+�a#��@��7C�Xa�#�t�b�D;Xh�؇$0*�2�^�=��� �kSc��܏7, Q�E�o`�EՉ/�rB�r�D��%�FW�z���
���5���8�;�O� ������{�~�ADi~	= �Z��|���c����>��Zt����z.�5�-Zװ��_p��-�ނ̈`	94$m�l@�,���(�3��[�fAKJ���$�k	���Х�Ʒ3GP@a6A�)?��-yլ)�9a���O����,[�
��HOS
y(�}A�g���g�tZ�k�J����2l��az�1@M��!<�x�lz��P��N�&�`��p˽��G��6�Aw�)F�?���+���'b: �ӕ'�0�����2���D�B�㤽	�@=k�L-��2��.� ���h�����"-�W7j3;��h6��  ;Ѧ#0h?�=bn�!������v�,�t�${s�mW��`���쭣,�zmjH&����c��,�o��7���E6ڻҾ�Ö��M�Ͻq&�
��up����x�j"h�oY�DD��d��^��|��]OM��F ��GZf����a�������H8b�C��@�j��G9��>�7��M�$hk�Md�1�#��x�\s���<_5
�h���^� '��o(�Dh
�b��݆O|�a�9�5�|cSS~��qKD���)"8oGDw���v�oj��c������3���qvi������v�g:�Jޝ��F�C���'��0���i%;b.y�S߿B@tX8��Y���3lC��c�IBs��Np>N����|�Va ���޹��<��+4�޵����#��*��tJ&%I��YR�褖���T_Q�>����$�r��%U�/��)��2�D�$�M{���a�-/���c��t ����O�?9�ɣv���ر �y0����@YINђ,�8��Ӫ��F)���$)���ZϤ2ZR�UBHJ���d5*�RJ�����^��}�s���^x�9��FZd�?{�_EJ�_u4���)��wr��ܵ/�YG�K(֯q5��68����W�S>.We��/?Q5y��_Lh��
�q��|�#�
?�4��)4E�U�rO�Q�%Ew�Wpr΃��c�b�&pO"�c�����t�|�'��@Pރٱ
Og��I�<WK�S%��`&#\:�V�D8��A�p���w ���g�4���b�xl�	L��C8g[ݞ!������~�a��(+]�s��� T
�5�ol!:��+2B%W��%=��x�]�,z(��V*�'����O$�ub.M���׭�Q�D5a�� #/<=�����DGK�}㪹P�Xm�r�J^(W�V��8��dt}�����x�g�\z�i���pH,�E���l����'Ǵ�i�Or�Lp��s�v�ȱ�����	R`uUާ��h�%��0�?{��䓾d��9$Ll.�7��N�G�!�o����+H>t6�؍l�)k���.�c����O��M��j�/w���|���(�����/w1�	@ls�����F��c�ۍ2hb;p*��i����ٶ��������M޳���h����u�s��Y���3�'��߻�����������'�u�������i��o����m���Ǵ�:a���-��X�k��y��o%}�?I����NSw��6�m����+�/z�����E����_������J��@s����s�@�E��3�/��G��u���J�-�OS���5<���� ��"pU�'iES%%�������~RI�餜�2���A��rl�v~�ӗa��Lg���]��[I�o;L�3�v�{G��޵5'�v�{~�wo�p>]�U/'�|�����(��դ3=�:�t�tg����1��b���^O���m�8豻GZc{�G����j��p������x/�?�mTG��b��ن](�ى�:dH���E��e�M8'^᳅7�s�+g�`-i�7[���L�Ҙ���4�⭴ܡ���g?�Zw�G����ׇ����ِ�_'�1������q��*��'��?	�_�������z �����w�};����Q3��&��~>5����k����@�W����*�m\����_;���=�3��U�Y���#�_��U����Rs����� �	Gu�Q������0�	����/���P�n������?��+B���Ck@�����!���V����?����)�����V���nHg+���?�Z�?]L_�?���'�#�������{�����o��(:�'�ʈr~�����'�6	���2�^g-��zq3��h���{?�e^��Ru�]�%a.�=s2��>�,�m�d���vFs�Ez齾�����|��g�˓=�)Q�ȕ�-��q{t�L)�d���ҟm׋�nO��ާt9���Y���S"=G�<��e+�;̡�()�����HR;�$ph�;M,'	�-'�v>c�������Vs�s��B7Ӡ�������iA,�z ��������׆f�?�DU�F���p8��@��?A��?�[�?��*� ��������?��k�?6���4�h�?�%(�?M��a��>�:�o_��k�o�	�T�ra��f&�qR�7��������뿔��;_t��z���p�uvlK���Y��p�I����܏6����l�O����ņ�Z�WE5*p��en��N�5���Vg;bCW����{]
�P<����N��B�=��+Q25���G^��om�[�'��RШ����<g�V�5ClC9���Z��� E��X��X�g�)��Dq�]�����Z �l���ť�t��7���������?�8�*� ��/Y�B(�k ���[�5���o>O�_���M������`A�� c�9��>����~�����lpA@2�ǰA�FL@�<�c!g|?���������?3�?+���:�b:Dۨ� Y�q�Cɟw�o����j��}�w�/��&�ͭ�-O��<�i�W4�"편�� �e�=���y
��r�%%?;�r�EJ,�N�/a:�whDG����Uoޅ����	����5�������	����C#��jC�����q-�~3>!���P�Շ�Y�S����:m'Y��-a�3κP���uWm�Yz|���>���ј��K������xd�.�EaŁ$�]
[G�(�H����j]�B�.�-ۚl
�Ȃ��TL�P�wi��ފf��	�kB����Gp���_M������ �_���_����z�Ѐu���e��A�����?��꿈���?���#	^x�L��YƕX9�����Z��Ka����ގ2䪶�?r ������U�><�*U��8	V�C���x� �<-Rj�h���)���Xck��@��6*j�B���+˒G��Vd��}V�
ʼ��F���t.x����Ê7��f�A�D��@�M�//����z�� ��]��1R��U|"��O�Q4��i,�>�������T�3��d�h�.E����Ŗ�ފ�;U�Ǘ��q���'������5L;wm��{e �f3�+��l!��-�2��~L��ՠ/��*���J�E"!�7�ޥ&�^�pEt�\�vO�/�f/4A����G����<��h.�����������`��
4���W���������L�Ƣ*�����%�������������?��_*�8������Q�ν9N�T�y��yC�!�q��?���1���bC�c�;?M����>���>?s����u��z�Y�6�бO�ǂt���Z�1U2�N�&~���F�?�E��bY%��ӭ�q��˝Z��nHq��7�a:�ei6�˘��JDWY0�cWw��OO�m�0��M�ߊ&��q���?��T����[�Cݯ�O������g
��*��g�������7�Đ��D �����q����_E����ۏ��vpCP�o�;���W^�������ql�F�2G��%��q���n�;(k����e�[!�%�#�߷ǐ��������.��9�ބw�Eyu��s䴳h��ٲ�q�?��4�i��3�������ד1��������ͭ8�u�e�]!s�Ū�>��R.���V�-�u�� �^����~���H~�8��9�ޑU�G����6���
���f����]���Sّ�+����i&�HJ���YHq^��]n�+�thm'N1�O���Ȣ5&���<m���S�B�٣�L�zw�a�E�x�47��������wU{p�oM�F����M���[�5��	���ךP-�� x�Є����7C@�_%��o����o����?迏�y���H@����_�����r��\�������_����
@�/��B�/������������?f�'��u����������4��	���I��*P�?���B� ��������P3�C8D� ���������+A��!j�?���O?8��?*A���!�FU�����?T������G8~��������6Cj���[�5�������� ����Є��Q�	�� � �� �����j�Q#�����������,��p��ш��A�	�� � �� ����������J� ��������?��k�?6���p�{%h����hB������a���������?�8�*� ��/Y�B(�k ���[�5���o>p�Cuh���U�X�2�X�ĸǇ��򹀧2���=, ),�p��xg=��(�f�?��O��&�?��P�ׄ���Ñ:�V@��)����ӽV�¿U�b+��7`���E�/ji����gw �1��Fg�$��-�A9��-q\�C���$e�c�v��.۞Ķ�1�����B���������3��8������G{@����/}�kc�&�e�K_K��U��04���������@׷V4���_}h���Omh �?��?�e`�o�'D����3�a@�������j;$o���]��s�?���_������v�έ��%JZ6q8,�y�es1]b�q�yj��s[ݣ��(��Q�\�v现�uy8 ���Gy�]�
m@��V4��w�;�������#8������&���W}��/����/����_��h�:��w��?��A�}<^�����Ο�O�cR�HfkM�lu���,s���~��{�v7i'���v�~���d����sX�� mɧ5�g(�;����)d.��I�v�y0����Ge�DF��bVBY��~Af�q����Jj4�=#�;i��k�I�坾e�=]:�6�o:m����g� FJ[��넕�#�.O�Q4��i,�>������&R91��d�h���@ �)�]��;{^֗��S�����{�i�l������G���]M�Eu4�����{��ϣu���@�Ѯ;�[�qO���vG�{�?����z���oo������b,��J���������8׿4��é����]	>�����#^�E������p��
4��	���R��U�����L��*�����[���r�U�5�ϰ%I�_����ic�Ә=�8/��K���:p�/�����,X/��m�4-:ώ�|}��^i�����S<Y~�{��x������Y(ї�o�k]z��X���uys.o�%�_cK&�`�Q��iUů��.��m���mI���keLbdHk�d�����w��	�	��\�R#B)[����fJ�y7��q��C&%w<�W.)�S[<�h�'+��}�f/���zY1�)��Y��~��/�ׇ�.�KO�����(��ӟ�{�%��mYx!>ʶ��Nhפ[��8�Y{�޵�q�#�+Ȣ"�"���'�գM�|���x"��0���p� TB�!�Z�H���A=���3��m�B�sn����2�\l�&�5������~/h��������[���Oc>����.8�"<~A�w}�b~�Qכ?�X,E��d}&�,�y�� ��f�G�	����������J�3��e&Z]7?���O|Q��a6��{ou{g���bN,]1�2�/W��V��ȕ�Z����⣿�7���c���M�8K��?��*A�p��*����s?�G���������y_�?5�N;�š8�
;�2�Ep��yv��_P���)����6�}����q?�G�������������^|��y��g�qnuM���]��HL�%�a{e"<3�&'m�opc��T�m�l���2`i�A���٥��[L��݋bu��l?佾ߋ�<��<_)7�(�Q,8�NK�X6�:�^P��E���t9�ٺ4��'���N;>n/��f�cv8e��tp-Q"��Q3۬�"@���� �a�)/pt)n�%��-���O�U�BUO,�pQ������^��G<�����JP������
B��p�\pq����'�Å���q�]����;�&5�5��ϧprR�Δ'- ��=U����~����"����wh�t'��Nv�Ŏ�*�E@y���w�/����H���!J�"t��!i|����W|��������R�Y{2a6$Z��}�P'檖?P���+Q��΁������uے��Gm���������?��ǒE��K�,����]�?�_�q�kI�/��I@�A�Q�?��BG��.�A�!-�����*�gI��S�[�?BR�A���cg�e��4v��X��{7�^��~z��A�W.��_��(���e��ʺ9�Q�>�Ը������\��feyl�6�s���ʧ��B�_F�����\a�KW.����5ā��G�]G~]	/�e���Z<-fa���v���U��&'r��5��J�u{f�^�/GNg������P߭��4ꮧe�f�mGisn��´�1�ɶ�l���^&������y�G��qQ�<���N�l8{�>4��iS�-U{{e���h��ق�0l��[eh�ڸ*�Ջw��(s���jƸ�6���T��e0�D���U�/ZJ�ֶӆX=t�}���J�*�U�Z
UGY�2�c���X�8��}�CoJ��W.��ɂ�#n���R!���� ��*�߷�˂���O�HS�a"h��D�=��-B�w*��O��	�?a�'����{���1� 2	��������0�����
�e�L��W������S�A�7���ߠ�;���h�ϫ�>K�k����O���C&������?S"����-BF ��G��7��B�o*����_���������$����O)�R��.z@�A���?uc��?2��Pi�����������P��~Ʉ��o��B�G*���������eB��W�`�GJdA�!#�����?P8�H�� �������i�?�������eB�a�����L��W�����S�?@��� �Ў�ߨ� �?���������}��L�?u����J�l�?L�GE&��������a����	��30����oi�p�������Y��"q���)�	�7� L\/�3Z3��23�*�&eX��*�h�dK&aP�aYzY��Д��q����1x���/O���\��0�?^����2�â\M�\����"��2�ʽU��/���H��2iI�@�c3�im2�N��Ǿ0�|��ht˫�lY��_�v��[a����~õZM�<��A����A)(Lm�Т��k
�L��}��j*�[�zc�iے2���S�8v����%�:*�V���+��<�{W'���g�,��P����p��Y �?��Ȃ���t����>�a �p�dA�!�C�ό�x�n��N��Qa��X���Q�0�QԴ�դ%��PZ��I�����5k��˵n��.���kb�_�Da�����bI�owl�Z4
ۚ5��/ыc(/gۅ:r���}�P��
���l��E��E�����W��!21���_���_���?�����DH&��\��"��4�f��G��z�������k凎,�=�����4�����+��Oe�ӗ�>��~�ن��m�p����C�8��M��n^�mF�>��tw�gK<y��V4�o� �f�)��ʱ%ۈ�u��k]r�Xi3��u�]��~�k��ouvg����W)a�
7{�r��x��l��E����4�h��A5��+ܣ쟓�(6}>v~sCT+�c���|�ϧĞO��#�ө�l}� :�!5�V���Vٟ����2����&�P0E*�A�\|^l��5J��R��;0L�2d\kU�m���%Y���P�����`�GFI�����~5���&��0���Ʉ��7�X��4HM�����mz@�A�Q���_��Ӡ�i�T��$0�����G��č���I���bp�����G��ԍ�0�7���P2}������?�?� �?B�G��x�d��7����r�+@"������X���X�	������_�?R���$�C{��P�Ҿ��͏�M�펙�e\�h�t�?�H�<�D�c�G�X��X���1�#�0���~$��+r�~p��m]�~/����~;E'�U;�����5_�ڦ��`e�M���YyM4[k\�'ռ���S�67NX�xr����i��T�Q<u���b?��{I��n��j�xZ;<W�n`�ya�g�P�7[N���D�m�#N�,O\����9c�l�e��������春�� lm���`�DV����[+:�(�yלS+3?ݻ���P���4V��T���~:2��`���ߋE�Q_�{�������GF����!��J&����p�O��������B�S0�����ypԗ�.�����_&���A��!���
� xk2���d|+��T���/�?��ѦV��\�q��Pm���x�K��K�O��"پtO4�ƺ�2���%M�r ���|�(탭T�}���4r^+)�(0�FU�]��k(ڤI�:[�AS���DT��$����@ҡZd��V����ׇ��s �$	��� `I�� t#.�r�=�����qB���p1��2��l�2?����m����������$��kJ{a�Q@�:��ukLt��>w�0��Ʉ�#n����R����8�+q�@���/�_$n�,���Av��*S��Y�b4C+�4sV�uҢq��t�&-��Ke�&�Xܲh��Y�,�Xr�0������dA�o��	����g���g�lϡܒ^�L=��e��'��v{�x�m��R2'a9Y��?n�d�����k��M�T�w�r���%�Ds�.jZs���̩���i�VC� ��٨Z�FcѲ|���c_t�1���Z���C�Ot m��E�P_�;'�?��Ȅ���d ���E �0���K������g��h���ޖU�0ñJaIi��t{�z(5�Τ��v�����	Gz;�oI��*T��s�UA��zmDc^x�Cz���^%��ٱ�vź�fؒu�rY�[h�6�w\G��\����d�����E'�?��{���� #$� ����_���_���e�x@4d���t�"���F����g�W�3r�m�@���(lq�jJ�_��=� �L��c9 �e!��9 ��촕Ȅ[M�������q��tc9��a�I����-Ec1-��azc�?_[j�<�N�V�^��U�4�7�-~����s��%>�׸��y�y��*�h��A���>�@�:���ح��������J�t�$*�^8�-kS�1�����������(6J?��,�cue8��Fz�T?m[<�E�<I��..�MW��MO6v(�ܹ�`Tr�W��ش��&R�־^�(�6���(��9�'F{�6$չ^�N��l0��DqR��r������sV����6���S���L�I�)���ipn�m���L_�܇�������������m�0'q|W>
��������o�*��u�!����X���	O����*���N���م�.�Wc�{����`��?�Ɇ?ޣ0�\�\]v%�f|�OO�/wj������c���l~z&�7����?�KB�q�C0�����������ϓ$��p��=����]����xp����Y��9��7�?s��aN[��;f�����0����縉�iě���I�|�B���\m���_ɞe_�s���;�7���?~��?b��ۻ����\�O��������zՏ�֠+�������r��.����h?����?�}�wnFr�����+�C����=�^����^�o�ܟ�����0KN4��Khm�\���ʜ٦�;�9�p�{���9��Ż�X��y�q��u�έb%�?]�� ؙ�ϵ�����}�!����{���'���n�����|�{��[��V��}uk|tg-=_O�x>��L#癦�?l|�x�?>}y}�8���&w#��/��X�����r��(̟/^������`Ս�~��+��$>;��oLhuŏmQ�~l��B�))�c{vuI��.H��Lᗟ���ݫ.�"9�������                 ���?e`�I � 