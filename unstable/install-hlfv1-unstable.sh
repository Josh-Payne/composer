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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
� ı�Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�A"�O�έ�U���Pp��-���0�c��~[t? ��$�?��)D$!�H��qI��)c�x�����X64xd���Y��=��B����m�,���,dv5Y����6�L�6�d~0`m�O�C����� SGj����1�b�lږK� x�%l	���3V���fb��{��:(T2���b6��?z ��?Q�h���N����Ȇ*�!A�����)!H���X[��A�2e����
�0��ӁU�b"�V,T�*���j�bc����n���jB�@��;���'�ٴy�Rl2i�&�k:Z<��7mM�k��,��,��:�� ���@�U]1(,�`�*^k]qb���^����CM�F>��>C��S�*jP����v�2Ga6Ud�[���gԧ�:�z��(ۡ�G9�.`��#:����/;��|�X0
�e+��p��Ej��N>M���P9\��,[�㍿i�2~1�;=~i���sF��S7G6����5�GY�Qyl�)ua�H��Ou	3ߔb�y�v
eLĶ����5����3���f��ա�{�]��4�>�%��냇�}n+�����u��>�{�ɋǣ��?
����(JbT|��ޓ���3��Fč�=õ�A�y�6��G篿���F�pX����±���
x�]�������SA��(*��j&՘��UR��~��S����6y�����Sɧ�C�lf��u�f�?�}���U���Z�Wk���a��w�҂<��q/m��?i����S�[���t�����6�c'b��Q�t�h�d�
+����Y�9�ul��Z�Cň�i٠�tg��1�.�i�l�A��D�fc���'<��6���В'M�F7���g�6ƺ��9oS�C�nbs��)��p��k
2,ֶL���a�,�&��:���c{Yӱ�R��?��-�;tB-ڑ��4w�AvÊ������o���h����Ժ�o8z�=�A��C����h�d!���.J�O�`"8<O`��ƥ�>���>"�=IL=�!5�� j��&��������i�v�.��/L�N��� 
�Z����?�	�^�;;�vڠ��:��
L��]D
0�Ќ�襐���,w�orWw(�<}�2>nrZ����H<��v σ��(I���41��H{�6$�^o����� D6�z-�~2�\]#��'�㭇�^��6�f�6`A�N��Y����g��%� �@���(l�G�������w�-�F{<�a�@��c:hW����ߙ���9�YV����>n�U��aC�	�_=<}s�	�.}:ܱ"u8z�\��+9��*Ѿ��|��M2Q.wX����:�ґb�^SS� 3��x��h�<g�	�l���:yo�y���y����l��?���+�	��*m�)�񏲧�d��
���`�ի�T�>�;5��W`]#x�B��rdA�S����K���2ҽ��P���O,���>���a������X"���O˿�>�]�~Rzt�zg��;�!��>��Qw��:�Qo7g�9�I)�A�l��t���	ꄫ��+*�r����3�Mȫ&�?{�]��<{z5�<xF�Ĝ��%�r�r��O}8Δ+��⋋��m���	�Y�1,d�$N��in�����k`�U�!�B�i�t+����#�Y�S���JU.W?T���Qu~�'�f�]���"��Z�׆0Q{G��c�~��v���H��E�~޾Og6��g��D��{�oI�s9��۠H\q�]C&~�>����@�u�,��N x�J���߀y*�;.��lAP�I.�#6C�+d�`��N΋軋5����k�o5����l�����}��e��i�/Y����_��'���=1:m�dAtյ0�㄰�Aϲ��Νa��O�Kwoc��{���?A_�� ��?��܉n����z�W7]��/;�⑩��Dbk���z����pl�=�i� �&6_�����B�݆�j9��.��Ȧ�X�	�䘈�˩ݝ�f���?�����4���c�����'X�շl�4Ȉ��5�9�EF������tx+�S%�r��t�Fȴ���c�4u�@�Iو{b�A���?��3�o�W�m�=at���G7fB?�5Ģ��"0�Z� ���z�L���ޙ���k8}������v�~pS����e�?.M��D"��[������P!��\��?t�6\]
Y�茨����kAnDk�ǁzO�=n3�BP\���[a+��ަ�w}�Vm`Gi���*��������e��bS��F�����qY,c[k4mP�;���!���^C�p�����]����]^
-���M˿���Ww��y���f7D�;�Ч�C
��6 ��'`�9 ��lc@�v�t:�rJg������hG�$�g! ��ohsZ��!T�n��A� ~�ᬍ���^��]��l)3S�\��l�(k��6�e�IF�d^�/}�t���:�L&�Y���K 1#��Tj���3&Z�N�1+1�D��\�C�J$��j���,� �<ʼ\)cyf�� �܀#l�E�̺�4�1Є1���8R��J���b�f}A��y���j�Oh����b<,���W�^��s�SоX�]���h|��'���+����>p������?�������?Lٟ~B���HR8�UWDE��^�K�V"��a)�H���DDR���&b-�׶�э�������4�y�_���;]#�qD6��o����m�ѷO9.����7�y㟸����__m��I"���7_���<�{����������w���?�!���ߜ�d�jZ�xL���/�)#m0��q~��߬�{�]���3�Vm�^�G���_|����&o������RL����*���c�'�[M%e�Nc����$}��:�?h�M�����S�N���W��5�9[�m|�>AE	��Z]P�[a���@uE�m)	)A�'b[*��$(P܊�DM�C�����&4��� �V��
��($3�|�2�j>�O��+}g��T�<���TC��r#_��΁q\|�WC�\��k8��K�T�4�����B������>� �r�x�I6����E�R.'�cB��j���ޮE^;�$s�=���gJ5}L�i��;Cig�Ӱ~y޺�U�7.�fr���e�9{�l��$��J��.v�2tq
�L��|g�gb�v�J�PUz��|�P��|�����2aX��89O�
%��*���K�\�����2S-����K%{�pւ'g]��V3'�d��E���8
g�|�z=�o���L����띔N�6<��d.�B%��\�Vr�~�حU�gd&��\��1W)H	��ɥR��^fW�r2�l�]$Kb�uQ���~7^|��G�X���I��:�k�N��z��~
��,T+�-���g�^z�X�筂zX��I�~���;�V��Y"kAz��{�d�W�k��H�:׻�BR�oe�sY.�,:*5�+�
�=9�l�gЉ'���;�,�z{폝6��<<80�T6V�¯���˝�����L�BC.d�R�RJ��J�wF*��X��"i^&�'�P�8{O磨b���ݔj���^����*��Lf�B"�T�o���P��))�ţ����`,�)�g�?��`�}l4�5��@:fL�3[?�_�ܐ�/ �bL�=�ԟ	�c{޲�R�D�W���}>��װ��_���L����bt�����cb�^攕>�
��.���"��	=H}�R�!���~rk��֪�sg�Pߠb�D׻z6����^�;M�r�d�lvSV�X��Z�Y����<��)����cN:n�K�h?��Q��x7����q��S=�0T�P����w�j�d���ǜo���s��/~�_�n��k��
�l�ߩ}��/���g��u�ϕ���?J��S��?��ez����GJ.�G!i���K9�=3�M�j�u���,�nt�a;��ٳl��A�S>{�gˉ&�2>�{{��K۰ۆ|��-�w!$v;F���i���3n��{��g��� ����i`I]k����D�c�㿣�:��j�	H�N�dq��d�|3;A �:(�2��5�=�Q���7�}7�m�=˭k������ �5���@:0 �ꚡ��)\�Q]��.ف��Ѐ��ċZVم����X�O��/qJ�k�h@��Ψ Ҹ5c��W���n�R�+��U� �k:���t�c!HT���F`,����ue�ct�ز�_�x��y8�s1�l{����!>(�2�#Ν|h�}0�G��q�v�e:�3�"�t�� ����M�j��hd"g}�=�P;&�  ��Z�G/0���r)�"PEd���^���R��a��� �4a�6HI�lSC��!6`T֧m[�A�{S����=��8 ���GG#ۋMPm2�_ؠ(�K`A����E��I�9Æ���ʀ�&�5Pn5�Mh�� &>�������$к�"_�?�u����h���'fl!�WW���� ��r�`�/$�妭�k�}2�]�;d�u�Yg�}����JD��6_Y�h]�����c�vz���2��.��<)���e|�	n8N����q����T��SA��.�,b�Fpfv��9��\��p���v�7�=�@D*ml"O��K3�|�[4��E.�}� c<��@����_���@�Sy��@O
;��lw�b��#���t3��2K��J�/ݫ�4_�|m��<���9o���;t�I�T5٦��.}**χk���"&���Fv��U�tbhR�c;tB�RQt�"RDt�pl��a����T��ɚ�5(mwtL/��D\6��h�9Th�=ͧ�:�`]��tX�9�	�e�v3���M�}D�����vȒ��c�.�`@0�?��`�td���Eߛ���R�
���g�@�1TU&a(�����-�Dz�o�B[A�#&�X������w-��ci���i.HM?(�!T3ݨ/U~$v�˔�v�$΍�t�,���I�8�;q�*iZi@�A�f;$f�����A,X �X���#�㾫ruN�o�k���_��;��m��)�8����Ǐ���ԏ�,�ǿ�ϥ���䯨��A�犁���/��߿��o>�������8�=Y �q�����u�c�~ܺ�.&T����T(�	��!9BEk1C�HS�1�")���cd�#H���8A�m)#��I4��گ����o���O���ʏ>�ӹ�������~C��~�����+�����}�6�_���������C�kB)����/��!���-�woA�C Z� �b��E��t3׍F�ǆ���R�M��O�N�����K��%@W!��W��*ć�jL�.�
�QU\K`F6k.�u��"�3�J����%M��\�H�א�g�Y�{�)a_�i�Vi�"
E����9f����1�-��+�f���R�����0�m����	ž�0a�Sn�X�o�3�J�^��f�<�1C(�f��7���%rw�kT#��Su�����1�<M/���9�T��a����~�/�l�/�cM��N�҅j1u�o"�e"����ss�$�e��Hv�l[H`&�Y��t!�2�����@��1���G��I�I�?h�5af��\6i =[�c9+�9�S�$%C;��\'E�T�ϥ��H�fw�f�6Zd��~�;>ob٢Ue��;�Ť�j���%�#�<��屚)S���8��[_�f��8��i�2II�j�l��0J��MJ�͍��+"��B��������<��+��.�K��K��K��K䮸K䮰K䮨K䮠K䮘K䮐K䮈Kd���`�E�,�h"��IR���QJ,P;Ǟ��f5/Ƙ�������Ŷ�!�E��(p.T��|� �sՃ��B�~kՃ �s;�5SV�=ܼ�5S�S?��j��2OM�X1IOCs��7�l�P#��Xn��,��b�ї�2�B-M���Vy*�(K�F���X�6����Im�@]�~W��D�D#�}�caLBbe.;[�r���S9��-M��y�u���'C�f�XG�\"F)� LvH3�3e�L��NL]�!#��~��k�=c�l�O(\2wZQ�r����򈌵Y��o��Y�p�p�wa�.~};�G�>޲�}��Go��[����V7��_½7v���ϐ���-�8��[���HS[��'�w��8r����ɇ:�kP���^<�Eo܁��՗7o^�:pQ��} z��A�_���>r~�G?t��?y����<�ރ�~�(�,-Q&K+���YN�U&�TY.R�Qr����%�E��K�\�'6��e&l��r&	XJ.�6V�`)OWr!������EW��:��2�M	\��+�s@��-�(U��N�Q<�RØ �Y�F)U`�x"�Rq*}̎�J�W@bT>\��ʱ��0�YO�,�PO�-���JK'Mc��z�]]��tG������HM�s���BղTw%�f-��t���f��`D�*�!-�l��2qFjrˁ��hG����q�r�RrtnI����'J�n����%}��)�N6E�G��ZS�|-���ny0�����"�~-gY�l�}�/�-�2B:B3��1���q���nXS��a����a��Z	�,�H��=����d�80����\��Q�/
�4�ᢙ�ޙv��-�?~���,0���3�rbIW\�d��~D<�b�5V�B[_d{�"��Ymd=��g��̬������m��ew��=��tϲ��fU���S��L��=���j"o�:����zR��J�-�%%�A��U�P+�e�φ��Q��Y4b���:/�yzU�>���T�~��
��C�+�@����نr\�i��f�/����Ts�u
�0�I�泎֞G���SkO'�:����J'�L[��dUX,�]Z����Z4�$%���Ų<�ҥ�,�0�6o�����Ţh1L���d*���S*�E�vk�0����4�c�/��hzYxv#��/�䉬�b�H��lPkjd*�1&#w���e��Mv��dd&iG�����!�=��&T&�m�`\e����K��dm�\eR漫P���j�RJC�r�u�V�sH�<ժ.6�X��u�]%��F��wny,�qI�c�z%#�g)�\U�ɐ��Ng*]v'@��V� �F١P"�L]<3���Ҕ���B'=CS��;A�RXH���S(�ͨ�(�w�i�МOqR�T�H�j�y����F�
>*[;LF-�c��ul*���Ps���ʆ���h���R��r�e��٥��]���oY6�#�]�n����"<���eB+��څ<�����-ZTtc��_�Gn�G���,8�U��Tc%� ��>�F^����0���ԥx/���������ϟ�<�BށyD�QR������ʳç����"i�l�����kz���+�7O#R�B��ZgdU� �qD�7�'���q��!9J��t�����u/;�<p��剢� ����S:��u�^�^f�y����n���������0]���B[��!���o����6��'�~0�u�zd�v[�~'אn��;�0�JP�^��`����[�t&ê$=8�&�@1��ؑwR{G���}��rF�������>G�&����W����]= �;�9	~�amT���!�G����y�tu���}f]/���u��+Z�Zu��^���9�щ��z�|.�vL���������"�	:Y�G�	j� �G�~����( �h#��f��D��Z7 D� FW��BE_�oL���v����4Zcp�X�x�,Υ�`�7�zw4���P�t v9�����=_ͩ�� ���|�V�ت���ć��I�I��,�QСwA���9��
Zt��?_} k���������*Ù:��^�5�>蜯6��Dj���Y�A����W���_��'�N\l+Mv�dt��9��u��5��*��:	�]BG^�WĀ��Mt����X�Nl�Z&��C/:��VB ؆��:l�cI;	GV�'0\Y-j%�ȗ[/$�̀\1�ces�7�ןzP���f���	�v�!a?�Z[�o�ŦB�.�Y������Hס����:�n��CG�[� :l*DO��a�7�rMg��[�܇>��Ih���X��F��Q`[����$%�I��4�\vu�J]����EP�͖�Z��P��b�	�l} �u�dM"[W���6���	rO�;��y�6��� @�+�K%��D�Ꙥj�e��~�%CL����K6��i�nd�����+Nx�h��v�b�c��� �<�б�~��
"�G.j�P)�ea=���� ���R�������e 
�9� \�U導5�"̓�]֏�Hsu0�j��v�L�P ~��{(ܤ�S�B����Mk���n�2Úd{�����6A.��~d�xk��^���fK^uqձ�+�4a��4��߻<���Ŗ�/�A�}l|��۰�-��V}5Z�;-B$�E����[�d��v��|x�]M��SgFN���Zf&�>PV�5U�t���H�P>fu\�뾊�9�;x� �?�Q�#c�6q���8y���9'1,F�$��r�c�]���v��$����l(�D �n1����+��0Ts4�;rc�R~��qC���~T��S��Q�b��];����^s��u�s���7W�q��2Bl��$C�p���V2�'�'H@m�VɎ������N�d�mxV��4S��gq�D�x�*F�Y�C�;
��b�+�߲�UŎ�"]V
|<K�k4�ڵ���8�}:V�h蔫߬� d�"�&!IM2#�)!�MQ�VKi�r��K�Y����n�c�G���3�o2��|���+v��̉�cY����V����o����)*�r�Q�Xo��:���fU�1�I�R����Q,"K2N(�&�$I��pL�`Q*����BHH!k&�1%Qp��kb�O�v���sl�ȟ�٘Yv�@�M�S��{疄�\w4�8����{r���ʸk_�����Wp���m��rE���\�+ҙ�L.��*\晬4�����%���,[�J�g���s�K|I��T�}���Ⱥ��ܓ�.�]2�8�Jy�}�;�*7�t�Յ�>vϺ�
��{kGv&��t46��������vT�;mBZ�^�u�uT�`t�e���;�&�m2u�k-����0Q�:����Y��> �M��\L�[Q>/��x��"O���Y�����S4����UN�'X�)'׳V�3.��s|V|6��E�=kt&M��t��VOu?}��3�"/==��u��لGK�}cs�S�h*W�l�O�e9��+�
�螹lt濴������ۙ��v�yZLm���,�E�ؤU�$�"g�di�f��,B���%��r<�2Θ���	r#���h��2���ӣ��g����gmIӕX__$o���=":Y�����54<�Ew�n��X�[����+��]V��P��Vw�y�� �ȥ�����w����wǊ�[�q�2g�b�jb3p(�pTtz}������]/���,�K��"��/�Hw\�m��ƍ�?d���a���^��o��۬������Gz%�����o���{����-�6aCii��O��/�U���m�2>��}�}����O�=_ٴ/���_���������^��������@s�,}��J���_�o/i_��"�$k�V�(֎Deܒa����Rd��D�BE�h;�
��P3�*MLV�0!����E�_��*��C�m���%���0�7�i��k��P�#��NS��qEl��)�a�|��B�����'��?�*��T��5�A�ͥ�3rX)D��H��ȟV�e����R7BҲ>o�㧓R�ޛt*�IWK�+!,��j�:�wǨ�^����v~��U������K/_��ؐ��!�N�X�ۜ������U�����?t���H���`�{�_�t���������D���?@j��|��A�����<�}�s����^��� ��h�� �����?Im�� ���^-��~v@��/�K�_��Ԗ�'B����H��ޕu'�v�{~�{�Z-�p��1���8p�.&'PT�_�i����I�*@WξJY�����9���:�N8��_=��S�������G)����](�+��_[�Ղ�������P#����
P������?q��-o��Ƶ����?��ן���د�\'�������E%���&$��O��������1D�h����~"������ɬ"�>��y[�D���SAb�ˬ�j�,���v��53١�������{}��R��V�o���x�i,=d^�Z��Ķ�1lm����}{�������g�ݯ�L&G|/,~�n׈ӥ�yB�GC�$��t����-��{��y�h���^��r��Ǯ���lz׈RR�_�j��J{��m�v�c�����叩G[��~�S�4�dĘi�(3���iP����P��� 
@5���k�Z�?��+C��R��F-���O8��]
 �	� �	򟪭��?�_����������_[�Ղ����
��Ԋ�����:��0�_ޜ��.������N�u̧{~F�j��m'�o��oe����\׿���3�5���z���`бS�!O=��x�p<�+-�z{c;\+&��T���ѥ'��5�6r��J�cb�I�f��3�?v^��f{3�u]�����k]��?����N���|�>��A4r%����Gn}������ʜW��8�k�%�oB)	7��R�2;A'��V�6j�1߷N��\��{�b�ÍJ���@�ĳCq�H����_�����{��0�e��o��}���� P�m�W�'^����_
������Fa���X@��G�Jq��!�����4�Ҍ���>�SGxh��?�:�����������ϊ��.N�����N#Y���]���5�5�c�Y���6���K������9���ѓ��p�j���i��{�n99���I��!zَ��,�cI�{tp��K������A��ߋ:��!��:T|�߯��[)�p����:Ԃ�a��2Ԁ����2������_u����A7d�ʍ�f1�����S������o���)3̒í��{ݗGb4hƌ��3�˥z��Es��r3�E���2B�QF��D�Gf�ʅ��а��:�����GU�iy��{Q��?�oE����w��w��k�o@�`��:����������Z�4`���c�;�G����[��).�/����"r�y7<�'L�$ar,��w��������n����0C.jk�3g  O�� ȟ���3 .R�o�V���T��! o���YBm�o6z��P�d�/ѥ��!�F�)��\�6Ӕ�m���F�G=F��r�`(��z�N<�sQo�n����z9~�D��@ߍ���p��{z��� �n	�&\ꁝ�-�">~����w�Q4��q$H��]7�5),�O����t�V3M��7c�	��V�D�_j\D���7ܟ4��l��<RQuwH[M68t_hL�jG���LRz$�g��L�E����"䚡����H��j�N�9�o�1�G'Aǚ�����_�E�:�?�|��H�e������E����z?�A1���:�?�>����)(��!ӯ�(��0��i������C�?��C���O��W�R�ƹM���$�2�`xH��˹�K�$2(K�!�z��4����B�	1�vCX��4ԡ�4��B�����_�������t=w,�b�x�$�99׷#��u�L*|��5��7I#yp6͂\h�Fi;�a�a��|�lք�O�u���Q\����<�Q�&W�#��ᡣ�6���;�#����ĺ��E������J����5��g	�;�q�?�������w�?����r���1d������U�����_E(���������,����w������~������o��ߌ��9h
�s2a�D^����o��d�[�������s�gf���!?3�}me#�8���cc<ܻc�ܩ������UO����'��FI���x��Ԟ���xhu�Φ����ОM]�W[n`�1�1㤹��&�dZ0�)��Q�.,K�i<�F��\�9��zm;��qna�s�#(�솽e�����}���w�آ��R�u�S��ɶ�"����r���iH�n�Qc�9�8FR��܌�|�Š)�I�t�ֻ� i%r��J�q��D&#�3p��,�st{��z,�4�A�]���[��p�{]����u�# ��"���0^7ԡ�0�M��W
`��a�濡������~��PK@����_���աt��\�������_����@�/��B�/��V�������+��?d�Z��<F��#�?	�)���(z_���e�,�<������_=����U�b��p����_9�c�?@����?�CT������zp����z�?�C�����G�H�(�� ������)�B�aw�/����?��P�m�W����?��KB���B*@��G�$�?������������H�A8D����k�Z�?��+C���!�F-���$�?��������j����KA�_G0�_�����������+���怒V������?��W�������W��?�Z�?���@����ex���.��@����_��x�^���C���.b�CC��f�ϰ��X.�������$h6pQ� Q��X��<�q]�%I��_�Y���u��Ơ����Cet������[���\*N��*P�����0�E����$nr�ң�ϏP��z{�ZW-)�jl��|��"�wG13l}�j��h�"�(F�Z\%/�r���Ɛ:S�UH٣ގ#q>��Ir��x��>ߔ�ù'u,4\��6O4�{iw���~�k�:��!��:T|�߯��[)�p����:Ԃ�a��2Ԁ����2������_u�����'4�������ب)�o�f��Y�bؾ��68��|*oܗ��
�{�`���I���͕ ^$c6���~H]%
Oة�l��� x�a��O�S����4�x�s�P����,s�ҡ�{/�q��;��ߒP�������~���߀:���Wu��/����/����_��h�*P�w��?��A�}>�������7�'t�!���1'F�8�Bd���ke�Z�=k����Gp�X�-�@�=Dڳw�����4iv����D�ێc����T�X��it��c�F�^�E��3"��s܋�,�a�r�Lk'9r�����+}��{�t�u�߰[B�	���N��p���^C�\��.�iF� ��Ǒ y,V�w�P(֑²�>�f?�I[��|^�Q�0'��r�6?�7�xD���mG���;93�p����Q�XP����6\�M,���}#�x<��΄j��-�l�6)�l�����?���.w�o�Ǐ�Q��o)�����������p��@�?�|��	�ߥ�?�O�n0�U[�q���Ic���@�G���/	�_����\O��������`^�$�S������?�E>8������H7��9h'�Khw�ܓ~u�GK��[����n�&y��q�.?��+]!=�Ck�O���s?n����3r9z�����֥�	�ͺ^�˫syM-A�[2�xK���U���� �ׁ:��!{�b���9�����k���mt��b���8{tS�p�hX)�xΜ�MJ��0�^�v2���U��1��]�������-Z���{r��魝��\�\����k^�7�y�f���ij��{"�"#D��{SkK4c�)r7Ć�&7���1��"�O��C�.�u�W.s�wxI��X���d,"����Ƽc�	w��5B�p*��)��MW���=�k/���7
ԑ��:[��9�/�������P�G���A��$����B=#\�����܌�1��0I��%q�g3�!	n��G������!�clv�P����_�����_9�/�ь�8��2����"��#o�u��{����|������\��ZA>"W�j��ߋ���_���(����A�aq����+%|����1ʸ�o��������������~���={�[Y,��Y���f����Z��~�z��s����l�Ǽ��q?�g���������h�}���7��f�!���"ޛC(�V�9�"�mH� l-��������kT�F�FN��}��^�gi;ߟ���ٸ��[�(V���j�!��n����s=�X�ߌbޞ���0{��ly%:��i�L�c^�.^E�~|<	�����a��^�Gj��\N��%B)�id륝��z����_�hfH3�96�\��鍕E�l���2����̗���wC��h��KA	�ʥ}�i��Pb������ӗ�(&g�G��˺,z����pǨ�#�`�}"ʸ�?��O����_���:�:mc�֢��i`!'N��+�q"����/�Ɖ�N�����l��䣲����?�׀�����W��.j�^�����@����'<�����U�?�U����9�A�AY�������gp��K�[����};�јv��b�����l��E���>�!����&(�����s[?���(���-D�� ȉdɄ&M��B>��򬯒�c��cҷ���B��:W�G[W���tt傟������sR�����ܜԩs���Cz��V*�����[9��� uj��mw҉Τ3�f3q}���D��w���Zk7���J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���a��+ � 