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
� RZ�Y �=�r�Hv��d3A�IJ��&��;ckl� �����*Z"%^$Y���&�$!�hR��[�����7�y�w���x/�%�3c��l�>};�n�>԰�DV@ŭ6�Q�m�^�®�{-����@ ���pL��S�B��c��c��H�a!����BpmZ <r,����x˞�J��,[��6x&=�8Y]E�6���M>�o�uYL�B�ç�ނuR�赑e ������K1�6��#	@ <���m��+CfG���B�3@J���҇�A!��n�� \?Q�Uhi6��N����5�@�2�a�SB�ė�\2��	��"d)ZK7��iaà+#�B�X8��өE�H%��4��ݤ1ـ��w.���O��i�7L�:d�-\��x�M�FV-]]4|٪��oA�����:bPXD�!U��:�"�&�C��`�����l
�,�FVQ����]���K�9,�!����5�?�CZ�eЮ׭��
�������#؎	a��S��g��P=���&jP��V�n�R�΁U���E��b�e8����&�Wa��㗗�Ȁ?gԟ?usd�l�{Z_}t����ǖ�Rf�t�i�a�R2��N����60]ø��Q�s&r��j2���t�z�Y&4�d�v}�q��m�?x8��N�§�{o�:y�Xd��Ga��EDI$��,F�G r�=�_��7c�D�(�5=��wm��d����D�?�%I�I������_<�.T��P��Ʈ�"�?}T���t�jL��*��w?��J��[�}��<��{��j�S胁!q6�|����3��>]��*�����U�Z��l�!�m�6a�ml�K��O�{�'JBdJ��k��"�����:3��؉/�`�+�>�AFY���l�`@g�s�l@[d��An�C1�v�h�ݙ���-��5�r+�y�;��O�'<u��7��6�В'�J7���g�Ɔ��9S�C�i`k��)����g�*2mֶB����E�ȎT�������Xm�8<��ml�tBmڑ��4��Ivê����=�f��C��- -��w._w�6�?z,��h���h�B���<
�ҟ��xpp��J�K�{$�����,��$>�dP�����>�_�����a��ۡ���K�?�<���� 
�Z����?�	�^��&;�N:����,��D
�\����襐�+�n?��8�P�y�\c,�6|���xK��C�x��� ��_Q�&QHm`���(mH�����ҏ D6��-�~2�\M'�K����֥���� �ߤY�A��v�t3�	���ޒ� ڠ���y(l�G���������-�N{<�a�@��c:hO����3�M�s"2��:呁}��}�"��)¦�c26�>�4}s�	�.}:ر"m0z�\��+���*Ѿk�|�92QwX����662��nCW 3��x��h�<g�	�l���:9�y�����z&�M�l>��?���+�	�*m�)�eO7���� U��W#ĩ����Լ�^�u����ˑUN�&Z[�/f��H�v�C���?�HLX��U����ˆ�?Z�{jc������q}���������μ�vFC<=c�գ���nւU�Is-�R Z�x?��q�\i��	W�͕?����ae�g���_M��=���3x��j���v�9ˁK��f�D)��p�.�s�����;�@��k��yI�t�m���!�A#��d�?��C����$�V����G��t�r���R�|���郣��^O����mDK�7�a�����@�B�<��[!��)��#��}��lx��੅���`�%a��ܮn�q�!0�VY<��{�sK�H��9Y2��	�@�0a�>�U�\�ق��\�9Fl��W���A����wkpk�Obk�o5����l�����s��e��i�/���p���=�T���n�$b h[��_��'���-�Z��f����t�6�ɿ�9�#�u��
`���Ν����O���%p���KP��!�Z�p8���+����i��&ك[��ea�%h[���/D[-hjv��;� �Pk�������O��8������ef?��y�)Q𓏉�r�u��?F���Kz�E��=�A-@��H�YC�1���:����_�nł@m��^��^8����v��w읦�Uh� )qO�X5���{f�[u�b�p_=�)�э��c��"kL�V&㯃��9Sm�w&x���L�nw�j h�]���T��%(|������?�pd}�{%pw���#՚+����"����K!��B�xz-�h��8P����mf bP���Ux+l���T��ު��:Qe���T���L�#rtJ��Hx-�+�_���G��2��z��a'�� ��S|�k���_��tS���K����i��c�u��J��� ������vg��~H���V@���=dt��`,�j��@{UNm�P �48���$ �Y�hh�ڜ��nU����G�>Ȁo8k�'�7u�f<[��%W�%0����l;^�?��4�O�1��c��̿�	}�f��H�Ȱ1�hf按֧�e�J�1Qa,��P��<��=ȧ�3�,ϟ2/W�X�>,<���Q2��.x4�ML!2}�Ԇg%�nl�W3�������<���4�'�q��1&����U�����<�t.��Ax��_!�>��D�u��J�������o����������5�S�營P�*��,ŷj���r֪5Y݊ǣ�j\��D�����ò
�x$����T݊D6��k�/_sӄ7����Ni���/���6�������G�>�$6ml9������6lT��}��&���W�|5�����Y�;{�_6����mp���H��}"8sb�ͫeo�a�1A��a�8N	�h�1�`����f}��+����y��j���?,���j���n�&m,�������Bx��WW�k<�(�j�)�4YH�Mҗ<������<yz=��d)�}��z��������Q�!�
(��5��j[qTS����0"<�Ҡ��eA��Vƫb�8��H�4��]�*"j�F� N�B"��@2]��2��RI��wf>�KfϓIEM֕n.��s%���ǅ=-���𛘎�M��M�Os{�,wy.�	nW�L�
J3��G�D#�<>�_�/�R�^8&�*�f�Q��j��O��s��{�VR�䙞Ⱦ3�V�=���Si�"[Q�x����{g�i��M�Q}���ʑ�$\����+i��xg�fbvwj!_Q��󜔯䄃JN:�e�L��3O��|��&����b1��>>�LW�d��蒉�^Q���䬣�"��J�$�(z#��ޙGR�ͥ�z�'�s��p^�L��	�a(��I�����B��̗#�f5{a�
�j%qFf2��&z��W��l2��w!�$����E�(f��J��wb�7����yĉ��<��*���~��8f��j�pO��@���|�,v�
�X��k��虜�e�ݽ�J%��Wd���Z��N��E�ƻ����s�[�'��VZ9W�|Ҧ��r�b3��Sr��u�X"���3��~�����n	���KHf�y]z�%\��<Y��"ԕ|�(�+&e{�}g&�����)���e<r5̳�T.����Q�8�Ij�z�^��Eq���N�a:���cn����8�{���㱎V8*);�L���Bj���~?
�~��f}_7��c��?��S���9�Q�
�G`���3�oa�,�[��W
�h�請4����V��K�����?aQ����Vc~�a)wL��K����\>��%6YYd�Y��U,�!���O�a=כ��c��@9��TȞF�Ȥ�zY�+��� .WRQJV'i�
�v��y���؋�c��4��*�?����Q�X��"E��w��^O6N�#��ʁ�$�*�ԑ��O�V�B�|瓏���>��=��e��������*��������G��/Ͳ����+�q����%����MwOw�㏤R�����*֕4�u�t&u+�������E��ކ���cd�2�f�n��{�)�+��-���7/�i��aWܷ���m��J����θ���瞵�|������%5����J���^���������' ��=��E�y��j�b�D�lPB�/� ��FY�������,��#k���<��? ��/����<����"�p�FuAS�d�6hA�i�?j	�Xc^�Kc��?-s��)=��� �#8� H���m0_���mJ�/���V�����,�*2p�� QUc ����֕я��b��~!���g��xo��4��AXxГ��ߺ����ȏ8w:<������4Ȗ��:��h�I��jxW��w��cWc,D#i8+�a���y�ڵ_�@��]z��M�K��
"��ғF��O��^ �&��{�AZH��X:�	�4���m��i���ŀ�
C���ɔ��>�:�^l�J�I?��EQ^����.zp�N��6=�x~�T46Y_���9��hB��b��X�����Z7Y �K��.��[}���Č-��*8|�$�<N����D�ܴUz���O���f���4�$5�!�͗�Bv�2Z��������^�ƤLoy�b� OJ���zC_q�+�(vd� �6���4�)�
,����]�BkN���)��>�~!���EO*��F[�W%��$_!�6�f��F�'�e x]J����D^���i�WK��'�]�	��;�.1~��\�^z��h�%�Y�͗��n���e�65t����M��?̡�t�I�T59��:}**�k���&�=ԍ�ڡ���Ф�-�q����M����8�#P�Nç�t/�5m���S���^����l��	�
$s��v���뼊C�?�a?�T&t�m����I7��m�D�h�C�̧�'st��}�1����#��(��T&8��V U�>��b���1	�@���<P��p�h�&�����$��1���%�q,-w�4������3�j���ʏ�Nr��ڎ�Ĺq�Γŕ;��qc'N�@�!�@K �7�݌`��,�° 6#�7���k�9~�y�wUn��i��{��>����/m���?a��� �߽$��`(�%��?���o�s�/�=�+�o~���b�o������/~����%��8�9�|G�o����Go�b������	U���0��dE¤pH�P�Z�P8ҔCxL�H
k��n�R!�2Nd[��9d�B�������������?�������tn� ��Ɓ�Ð�b�����>��
E�����w�����{��� ���G����P���a�ˇ�z����o��[��v���+ ��2p�b6��u��򱡥c)��{e�a�S��9��{�|���=f	�U�m�U.�
�Ӳw��nT������b����0�yvIB�>zR�5$���~V�!BJ�Ǘt�F��EZ��BQ09{h<g��zu>nb��@�
ź���g�5�p�8Lw���EdgB�o&L�ᔛ3��[�̠�Wq��,O�D������<,�ͳ�z�ܝ��H�@�T�a���~�/O�f gλhչi��y}���K#����X�5Š�t�ZL��Hw�Hdg%�ܜ)�b��2�])��ɂn�<]H�m�}'9�(D�����za��dM�Y�3�M@ϖ�B�
a��:I���#:�I7�s�|�4Ҥ���Y���������ÛE�hUY��N|1�Z�g0u��2�E5ry�f���3�u��֗��i'�'kZ�LRҬZ*E:9�ҳq�ss�?9�Ǌ�!����%tu6��.���Jn���+��+��+��+��+��+��+��+��+��+�����1�w�7K)��~�T��d��α�v�YMċ1��ĩl��i��p��v�{Q;+
�U99_"@��E� ࡐ��Z� @��N�D͔� t7o`������Z���S�!VLF��М!2�<2�H�*�[��6K�X5E��L�PK��9��U�
'�R�Q459��Mpb46GR�,PW���?7Q?�ƈn��X��X��Ζ��k�TN�{KoEd�2C�¹y���ЩY8�Ñ)��Q
>����L�5�z�Sd�HGq���Z&B�X-��
�̝VT��(�&�<"cmVj����`��%\�]�B��_�����G����8z������c�y����p�]��wC�3佸}.6���0?���"�I�����ܾ?� u���ԩ���w pd�����׼\T,�G���G��}��o ��\��|����O��0�����_)�2KK���J��Ft�u��3�E��k��nm�|I|�:?��%W�ǉM�o�	[���I������,X�ӕ\�m�f��Bl�U0��#�LcS���J��~&JU�E��r�Ϭ��0&�cB�QJ�%�HE�T�J�㼒���Wg�rl�gs�o�S�� �7��n��ユ���IӘ7´mW��A"�Q�q�2£&R�-e�P�C�,�]��Y�i2�:~�Y:���4�
qH2�)�L����r�24�Q�r;y�G"���[h�`�Ҩ[��zI�"k���M�,��*�֔E?_K6q�[*8&*�H�_�YD#�hA��f������icL/�m�2C�֔��l���tm�VB'>��_f<��+�&�g(�i��˃�0�d�h&�w���rK��_��/���̦��X��@fٮ����p�������Ȳ�EVY�x��=3+=.�;r[~w��6~��;ݳ�D�Yզ���T8��B.ӡeO6t�������3y����i��`�aI�f��~U-��Ju��a�)f�a�nm��|�F�x��6�4U��g���P�
-Цm(s��h�<�����&?�;��\ G�B>�w������Ǒj�����	�B0�s�҉'��.Y|���i��+�FEI��}�,��t)2K#L�͛�!p�y�(Z�a�p4�J����s��.L�+źx?��!��(�^���&��+y"+E�X)!;�Ú�
x���])$lY%f�ݯ"�I�Q$�k?j�m�`��	�	r�#W� +;�Re"Y�1W��9�*Ŀ�Z����P�\i����:����'O�ꀋM�$�sq�nW��Q(��[�c\��X��EI���YJ+�G�n2�-�ә�D��	�(�U(��Qv(�H9S�C�L�|�4%/�C��I��T�<�)ļ�N��R���
Ct3j)���p�,4�S��+U�!ҵZl��g$����J���Q˨Ę�y�J��)0��(,���am!6�j��c�w3yvihe��j�[���g��x�o�y��n�~���d�v!��%�c�ݘ��W������/#?Ns��>���X	<���������1�3�d��%u���}�<x��9����A/Ϸ�w`�v�x7�&�����)�u|èH�*�>$����$��J����ȃ�������Yu��G���	��p�dHN���9���;�_+}���#�šey�躢��#�C����=z]���Y9B^��;���[|�x"c~=�/LW|�èЖ��p?|��Gz9�_��>z�	�:�G���Y��V���5����N� ��T�|9ص2����#�A�ɰ*I���4P�.v�����Q o��f_����'0���ϑ�I�3��U?��vW@��wN��:oXU��e��ѥ�e�p?]��xo}�Y׋llݮ��V �W��bNvt�dG�^6��S�{{��:����dC�N���Ѹ�G�ڀ"��=,iA�1
@>ڈA�)��Yt?Q`��� �3����PїA������a���&����� �1^0�s�$䍠�M598T,��]N}*�~yj�Wsj�2 ��,>_�� �jd�0�!�l�x�xK|t���]�C�8s"�������W��Zom���A��h��p�NFC�Wf�:竍g���`�`}?iE�<�Uae�Wa�ɪ�
E��c,]gh�cm�kd�v���N�k��Б��1�>k�c�,�ۀ��ɸ�Ћ�'�� �a~�[�X�N�őU��	WDV���_�����	?3 WL�Xٜ�M�����u�y�����h�lH؏���V��u���ůK~������&x�d2�u��c�������Б��� �N�
��`iA�덺\��Yp���7��O�x0�27�j��'p��yC��G I	|�<���E>�]]�R�88sx�n�%��}<�%��h+[�0(i�+YE��֕��r��m)y��S���p���t;��
�Rɽ}Q�.�z&��}�*i��s�����/���;u��[ Y춽-���/�x�݅�A���4 (O(t�Ǡ����푋�*T
6AYX��,�$H�뵃�`g�����z`u���A΀$ xU9�cM�H�`��cf�\L���+��5����
7i��悐1ktӚ穥�A��°&ٞ+��v�M�x��6��/��W&��YÒW]\u��J�9MX-;ǢA���.�/p�e�{c���_�v[���6,�i�q�U_�V�N��n��4���*Y�]l5�`WB�D�ԙ�S�''���ɨԃ�aM�!]�<���8� ��YW����lN�N :��O`����X�Mܶ6�4ND�b p�I�+I῜�FnG����- 	l�);JC:@��[�������c3�M���X��_�p�P>=�U ��~ԁ��x׎�e-���\�}�����o;�͕m\q�����?�P;���#���	�	� P[�U�#�-+a0��kD�}��=����Y�>�1����BwV��䎂%�X��,mU����G���|���v���?g���+:��7kG"Yj�H�IHR���E"CJ�lST��Rڸi�D4C��1Bn���%��QE"(�L�ۂ�=���� f>sb�XVi7���d�?��|b=y
�
c�\{;ě0�ξ��Y�xLjR��l6�p�Ȓ�J��I1I�(*S"X��*!�)�RȚ�hL	G\�$Ś���������'�'p6f��6P|����޹%�'���Nx�3���.*�2���,�#��+���l�+�\Ѣ�$��t�,�Kf�
�y&+�i��l|I�4��R��+�����_81�c����+��f/����k�*Ng�R�g���Ǯ�"]mua��ݳ.x�� ��ڑ���t��3�j�>i���N�����j�i];l�}�¶I{�L��Z�v�c;7L���l��9CV�Hv��%�)��V���=�+r�ȓ|6y��������g�9v���	�c�����˲���M���EQp��It2:��S�O��$h�̢�KO��y]n�`6���f��\��*�ʕ�x.���gYN�抧�5�g.��/��7��:���v&�]{�S�<:�1�j86i�-����?YZ���=����,sI�x�O��3&�/w�܈�d,~���m��(x�ę=xg�Y[�t���	��A�.bj��N�i��|��f��Ķ��7����B?&��
|k���2���Շ��Gm�;�$�0r�c��v�].nv��ݱ��VD�C��Y������
���^�l�x7�o׋6y7��&��!��>���Gw�q��Y�;qX�}���[2�6�""�a���^	��$���;���Gz��ohzK�M��C�C����B�S����Kz�?�c�򟌄�i_������}O�W6�K�_��'7�������t�@s�@s�@�B=��7K�(���#�����Kڗ���1���,��#Q�dG��f;D�Yj�"Q��PQ,��Bd$Ԍ��J�<LH�3�eQ�W;�
���o���_{I>�o3L�����:4��H+���9r\��hJh8�A��P��+�ye�In�O%�
�9�.rM}is����C
�1��-.��hY����Tč����[��餔��&�Jq��R�J�)�����1��������_~z�������˗�66��yH��>��6��8u8��Gz�?��8���>Ҿ������W>��A�߿��:�##����G�g����=_�t������l������W@�ë� t8%�:�����w�OR��:��}�WK�C?��P��K�����?���][����}�W�w�h�_�7/����7PT�_�iUL��ݕTR�;Y�b*UQt2�\k����$��* Gu�Q�pT�z�󇀄�#����G%@@��>�����[�!������E@��a?��P�3���'	�����ߺ����������w�uW�DL�t�q���e�34������V?����=��ݻ���O�}��E�~=�U�����>�k���"	v*)�j�7�R�^�ͬ�[4{�\��C��Y���\h����ut[��5v� [���y��]q��C��~#�������}b߳������q�<�GG����u�b�����&�7ݮ�lG��ާ|�/�kwy����,�k�l$=��7⌖�Y�LK�w�e�=Y�.������b{ˋ�,`������Z9*f�~���_�4@B�A��6 ��^D��P����	���m@��!%�j Q�?�"���J �O���O��To��D����� �/Ob��P����	�}o�����*��?�&(�?(��0�_ޜ�w����wΤs*�qΒ�n����/��o�?���Z�*�o<��ߗ��[�����f\C��Y��x>��F��n��l�����=��j^&NotO��� �RP���3f�t*���vȚ���/e=�׺>�x���ם ��B-闒lZ*���������Ʒ�?phiQ��S��N	�sZvW,���4�N+c��%���f[�۸-&b�9Slq�MZ�F���ɞ0jh��g� _<FHG�hcN�����H�?��#@�U��*��tA�_�����
�O}�^x����%@��g���9C�B�%f�4��� �paȇ!�R>˅$�8�!C	T�G8���@�����C�_~f�^�<}yN�t�l5M�Ӝ?�K�mD�A��βeLvqЖ?��[<?��'z�8��8b<A�݋�	9kc�E�ۯ&�u
��b��� �sJ��j�(no�.Q:�f����q;<k�����
����Yj������(�����H�?��������q-�~1~C���P�Շ�Y�MKu���8m�1����Y1Xw�۫�v�yː��<=��?�G�}u$ǃf���%g�Bfv�>U6ؼ��P����b|�yJwd7.�B�̏�o
�����RE\��N�1P�}+и���������G��_�P������ �_���_����z�Ѐu 	��q��"A�U����W^�_�~�����-�~t�L��Y!�D=O��g�Z��Kqv��om�9vU[�9 {y�� ���g��p��a{���S���x� �:�Sz��b��;��^�[r����4ZMI�Z��]ڶ2l�eH6bs8�q�DTg�1�~���s!xW�f헂y�n��X�YO��8��n9/�W��`�-�0�k=��b�%]�'&.����>鋝f"�}IJ��aߍ�r��ϛ�>e�s�v�ܐ���ZRCnm��7ъ痚�1i���'���Z���t\��V���e(5�S�#%�t�h�-����nDg���i	��N��E�Xq}ؤF�vƘ/�d��e�t��\D{� �G�O���
|��?�a�]Tq���������G@��I�I���+A%��~Ȣ*�������_��?����������?��_*���,�A��<���AFt�����,K��,Q~0���S$9ㅈ�"�g�;?(����q��T��9������2��n�CbL���(����nD��iЩ�D����L�X\l���F���~�u�S�b�%��dS�'}�TV3��X\t��svx��K
��^h����8�i�����?A?9���J����x��Y�U\�w��,E��_���������P���M�(���n��^u���	��x�����������X��������o(��6����l\fM�}I'\�����0����+���VIs������1�Gf�o�l�g��bl��̈�;Ւ��9��>��Y����l;�(�8s�L��9�������V���󩯋z˟�I���yY���i�1Y�V/��З�#��nc�^���~���X��qni���#'i��퇽U�ov�ƎB������b���2����Sٱh���Y2����j��iD�~)0c���zNј�ގ�b$��Y3�b���tcv/������j�!pG�����Ǔ�L�if�C��ʀ����=8��&T���|wT����P��� ��&T��0�P�������U����o����o�����8�wX�` 	��o���C��>T��/_��
������R4��U �!��!�������o�_����1��к�'�9�����i��+
�O��c�O�W������?���?����ׅ���!j�?���O<�� �_	���������?������h�?�CT����{�h���� ������! �����?*�6Cj�����C�����������ZH@����@C�C%��������?迚��C���o���C��6���Q5�����?А�P	 �� ������?���<�a��.@��{�?$�����W����+R�������������?����K���x���U ���.�!�GP�� ��o���S_�������Uxı�9���9/D��P�I*����|<�h<�	���|_�i�����;��
�O���5�O��`����tuz��۝k�)�S*��¿y��V�z��&M!Y,���n��l���Ӻ�Da9ԭ-y\ES���$�k3�]�-_�����D1F�V��2���w�!�I,/�[7M�N��H?��{�����G�H2�!)��T�/8b@���������a]�Z���������Om@��_��2���7
��_}���� ���8������vh���Yf�}��-bp>\�L����?'Z죽6�&�o8�~��f���X����c�kqt&�-m�t�G)���b����n�3�A�"�fT�����v9X��	�߷��������V����G��_�P������ �_���_����z�Ѐu 	�w��?��A�}<�������g�'u�%��=��'V�<�Rl����k�?[��j���S$O��D���@�[2�����W�6�i%�X��L� �;�͔`7N�N>��~"ڽx��Ü��0֗�R,˃��S�i^�^�ftI��o�F;-�Gm7�?�ҷ���K'���-�%�t}/�XmI������e�>鋝f"�}IJ��aߍ�rk<���>e�s�v��qY Ւ�wܝ��I�I@%�L;���ۜ{gon�B��[y��H�p2�����S��ū��1D2��΄iD��jη�������?���~���|�;����s$�+�G\������O]�׿
�P����O�����It�/dQ���~��q���(�?���_��
T���������������h�d���o��#����%��0O+�N�h�ԛ-|�x�����?Z�h��?d��fiZ�_7�����5��s?�v�b�a�=��n�a_<?�P�O=���u�R|�.�7���\�RK�?ǖ�ё��ӪI_\WC���@���R�;
u9k����؀���*��6��T9�c�?y��ŤZ6���ע`O�&#z�ɮ]7-�Ժ䏧���>%�b���-�b彸o����]_/k!�S�������퇽|�s}��4��=1Sb+�d�s{SgG5$k�-?"������ٱ��2"ϡ��V>mt��\��숊���D.z��KDLw+8	f6��#N&�y �6�&��H�F��R�6}���S��o����*qOm*���x^8쾲��w��y����oE�F�q�,A�7�	��9��a��9N�8���!GS�ܧ������#<$f���Q@������?���?s�_a���Gm�� �To������_��9`�6��O�>��?ʕ?��=r�V`��[�џ������C���U��Q����JP���?�Q����c��X���-��W��?�����S��i �/��'�l>��S���Ouj��x7�{����<����w���o��&��޽������~ط�~��%�D��Y��6�l��&�z|�g0�\��F��^�/BV�7A�Y�8�=Z�����lZ�8Ѳ��f�a����������$�،ѝ���q���D->_�i�NcQ��JQǞ�~b2�.������lF�D�^M��%ƙ�i囕[��~��F�_gxn)s����т^G�퍵e�n��������-V���w
��|6�������?�!F,�85�I�����WE� `|��}��Mx�3�`H�$��#/P`�} ������Q/�������:�&k��b��y�`gA�Fk�q���W�~��֙��N����{�rS-�{e�ߊ����~���q�_@A�]�ޣ��A�U�*>��m�NxD����u�?�Շ���5�AȠ*�����P�s$������|�>��hM�MMs7�q��T�����b�������א�{�C��s[�8����l��=D�� ��⨔�L/�R����b���c��c��Ǌ�R��;W�{[W��������ض����N�[�n��S'�
Pl�oo��� ��S�_h��Nt&��4���S��� ��{���Z�q�ʥ0}:�fuX[����+�������I-���(tƵN���u�CO�p�k�f������QX����7ǧڪ�`b���fqo3+S,�m�JGpK��\������V�Y���2����������7��>KQ�Ɗ'��͡�zv��(v�~��kkW�ǋmÖ��ac�8�*#[���E��~r�^WYMm�0&��)�F�Z�ù_U��^�Ģ��m;kV�^o 8�]0%�.[+��(U^��G�~yA�T�"��e��z���7�i�`�Q������LȢ�74p��
���m��A�a�'td���?r��_��E�������O����O�������p�%��߶�����td��P.g��������?��g���oP��A�w��ޢ�?����*��"�������?r���E�w������E�?�9����_�����L@��� �k@�A���?M]���O�R��.z@�A���?se�
�?r��PY����`H���P��?@���%�ye��?2��I!������\����dD�2BБ����C��P�!�����P����������������\�?��##'�u!�����C��0��	P��?@����v��J������_������o��˅�3W�?@�W&�C�!����!���������#9��AJ�oe��Lp����m�y��"u������78��LR/�sV3��ss�*�&cX��*�X��K&e0�aYzYK���I�I�ȑ�1|�[��'�_�.���φ�����oT����\����x���&SN~�%��u\��2k��@�ks�icr�n���ǁ4łZ��ضߠ��V����hO��Ң'��Ճ�k�[4}T��]��RH�l��f��
kI�\e�=��4U�Y�9�v�Z5�(W�gnq��[_�K�uT�AyEV|����]\��y����':P���f}�@���Б���t�����'n �V�]������G��f7iyW�u�11I,���l��8n��zږ�]T[��i���kTG�����6�x=r[�l��`�R�K�#���Rm���z� �k8W5��.����o������Jl�A
�S�'���Z���a�(�C�7���Q�B�"���_���_���?`�!�!���X���K~���߬��h��?��5?�=�gF�\���������>�bE��3������(ξl�^��	�"�M�7�$ɶ���[���X�G��N
|I���Ċǅ-��;<���d^u��4H�Go�km��������!���R��ۦ����s��U�0�"�m���z���@��5�kT��(v���{������D�ĉ�`�77�jEp�W�|/M>�ͧ$6_Mp�%�N-g�Օ�Zso�i�m���y�l*S!~8��ôU%L����0�!�.�����!C�G�.�������&�Z?����<���P������S����5�G^�� ������J������Ӌ�5��O@�?�?j������Y��,@��i��q@�A���?u%��2���Xu[�"���������񿙐'��*�ٓ��o���������?B�G��x�����������	��?X)��߶������������������ �#���qJ�?���JTڷ�#v��U�{nn�� ��#�u��?b�1�#M���X���1�#�0���~���+r'Mq����~��}��^���-:Q��OT���8�S�c֖]��u��1/o�V{C*��^p6dg�4'H�4B_��Ì5>M65�v_�i����}N�Ů��jz��qD��ah�iT��H����؇ceZ�{���LW'��]����y\u&�N��fD�s�3�I[��6��D7ܬ���5��6���'�nŢ���fmf{�a�,U�0��OG�_�ng� ���#���bp�mq�����_.�����'�|	� ����J�/
��3�A�/��������� ���yp�Mq�����_.��%A��#��� �5���!����+�4��E�Gu;��E$W.�Ԗ=hN�?�������q,������魍������{9 ��/�r J�p[+��q�h���f����ME����R�}3$0%�{%�rԧao�,�m��"��R�X��a��v �&�� ,M���^,�=A�ǍuaQ��B�R�}%Z��̹*6��.,jay��dY�J�Ȇ�MK��zdR+�5��4�EҦ�qݚP�V�/ܟލ�����������2���ip�-q�����_��H]��X�ς��?SfxC+��i�V.i�H�Œ:��K[4M��&K��e����Y.����>�ou����A����	����#���3��0nI��|���d�4�Z����d�k�֪fN�r�y��c��Mh����h� �[��v�j������.jZk���ܩ�Ѕ�i�Q#� WO�q��œ�e�8����FX��������@����@�n�'�?��ȅ�C�2����"����)n�<�?������?ޭǋeM�ȪH�I�B�m�[n���ZtwJ�b�D�������#�������s�5!��Cc�b~t�WG�,�x�N����vŇ�Wͨ-���T�謽�?n�uhM.C���Z���_��<� �� FH.� ����_���_0�����ѐ��e�`�!�[��8��l����0|n��;A��8nI�"��/o�=� �H��� `���(��p���\�մnArx��Zq���;M7V��9*���|*c+�h,g%>:r\�b[-��։���z�*�
�m[\/%qu����R;OԄ��}����kU�T�ú�c��,t�51nJ_�`�LJ���'�a�/�d7�j��H:q ۖW����"�1������,<e��4��D]��!=Uꟶ-?ۋ�W�E��D��Ҽ�Z7[�lH�H>�wɩ�P8��ٱe,/V����c$��B�=,�=5�W#Z]����·S�G�e�/g0~��/�8������G�������I�/��f��A�3�ܝۦ�'��@�L��s�p�eg�6��|/�� ��T�?v�A���θ�������������KOwN�l*��ǄN��y���E��3V������>o����Di����~>����?�qpxyP����ş_+�y��_����1�}�ӧ$�=n���ߘ��8������x�ߞ���;.�k����WN�{.n9A�fx�?q?p������h�<��B3���}��F�9y����.01�'�?�g�j�DN6�I�,��G7vA`&Ǜ;A���������?pc��?��o|��Q��?��ÞT�_��~}���;����x��J��=��� �����c�����I���.�'�����Y'o��p�����ӫ���]-/��G����6��8ᑇ?>]�n�kh��=���!/�v��6�N�-���w�pg�_
r �J��>�{��'���n��������rm�_�pm��onM��,��/�I2�ל��i�i���K'��������w~e<�_<ɒ�@-�isfd�ύG<��D>=Y�s��:���_\��Wq��xR�W�ةV{����n�����8�4�a��y^���OJwx���Y��{�}�O�`z�����7�G                           ��?F�6_ � 