
---

## **Step-by-Step Guide to Set Up Asterisk on Linux**

---

### **Step 1: Prepare the Linux Machine**

1. **Update the System**:
   ```bash
   sudo apt update ; sudo apt upgrade -y
   ```
> For this case we shall be installing from source as we change choose the modules ourselves, and this worked for my test install

2. **Install Dependencies**:
These are needed in order to compile the C source code
   ```bash
   sudo apt install -y build-essential libncurses5-dev libssl-dev libxml2-dev libsqlite3-dev uuid-dev
   ```
> please make sure you check [asterisk](https://docs.asterisk.org/Getting-Started/Installing-Asterisk/Installing-Asterisk-From-Source/What-to-Download/)
---

### **Step 2: Download and Install Asterisk**
1. **Download Asterisk**:
   ```bash
   wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
   tar xvf asterisk-20-current.tar.gz
   cd asterisk-20.*
   ```

2. **Run the Setup Script**:
This will help you figure out what asterisk really needs, that is the libraries needed to compile
   ```bash
   ./configure
   ```

3. **Select Modules**:
   - Run `make menuselect` to customize the modules you want to install.
   - Ensure the following modules are selected:
     - `chan_pjsip` (for SIP).
     - `res_pjsip` (for PJSIP).
     - `app_dial` (for dialing).
     - `app_queue` (for queues).
     - `res_ami` (for AMI).

4. **Build and Install**:
   ```bash
   make -j2
   sudo make install
   sudo make config
   sudo ldconfig
   ```

5. **Install Sample Configurations**:
   ```bash
   sudo make samples
   ```

---

### **Step 3: Configure Asterisk**
1. **Edit `pjsip.conf`**:
   - Open the PJSIP configuration file:
     ```bash
     sudo nano /etc/asterisk/pjsip.conf
     ```
   - Add a transport definition:
     ```ini
     [transport-udp]
     type = transport
     protocol = udp
     bind = 0.0.0.0
     ```

2. **Edit `extensions.conf`**:
   - Open the dialplan file:
     ```bash
     sudo nano /etc/asterisk/extensions.conf
     ```
   - Add the required contexts:
     ```ini
     [from-pstn]
     exten => _X.,1,NoOp(Incoming call from ${CALLERID(num)} to ${EXTEN})
     exten => _X.,n,Dial(PJSIP/${EXTEN})
     exten => _X.,n,Hangup()

     [macro-dialout-trunk]
     exten => _X.,1,NoOp(Outgoing call from ${CALLERID(num)} to ${EXTEN})
     exten => _X.,n,Dial(PJSIP/${EXTEN}@your_voip_provider)
     exten => _X.,n,Hangup()

     [macro-dial-one]
     exten => _X.,1,NoOp(Call to extension ${EXTEN})
     exten => _X.,n,Dial(PJSIP/${EXTEN})
     exten => _X.,n,Hangup()

     [macro-dial]
     exten => _X.,1,NoOp(Call to extension ${EXTEN})
     exten => _X.,n,Dial(PJSIP/${EXTEN})
     exten => _X.,n,Hangup()

     [from-internal]
     exten => _X.,1,NoOp(Click-to-dial call to ${EXTEN})
     exten => _X.,n,Dial(PJSIP/${EXTEN})
     exten => _X.,n,Hangup()
     ```

3. **Edit `manager.conf`**:
   - Open the AMI configuration file:
     ```bash
     sudo nano /etc/asterisk/manager.conf
     ```
   - Add the following configuration:
     ```ini
     [general]
     enabled = yes
     webenabled = yes
     bindaddr = 0.0.0.0

     [asterlink]
     secret = yourpassword
     deny = 0.0.0.0/0.0.0.0
     permit = 127.0.0.1/255.255.255.0
     read = all
     write = all
     ```

4. **Reload Configurations**:
   ```bash
   sudo asterisk -rvvv
   pjsip reload
   dialplan reload
   manager reload
   ```

---

### **Step 4: Configure Firewall**
1. **Allow SIP and RTP Traffic**:
   ```bash
   sudo ufw allow 5060/udp
   sudo ufw allow 10000:20000/udp
   sudo ufw allow 5038/tcp
   sudo ufw reload
   ```

2. **Verify Firewall Rules**:
   ```bash
   sudo ufw status
   ```

---

### **Step 5: Test Asterisk**
1. **Start Asterisk**:
   ```bash
   sudo systemctl start asterisk
   sudo systemctl enable asterisk
   ```

2. **Access Asterisk CLI**:
   ```bash
   sudo asterisk -rvvv
   ```

3. **Verify PJSIP Status**:
   ```bash
   pjsip show endpoints
   ```

4. **Verify AMI Status**:
   ```bash
   manager show status
   ```

---

### **Step 6: Set Up SIP Clients**
1. **Install a SIP Client** (e.g., Zoiper, Linphone).
2. **Configure the SIP Client**:
   - **Username**: `6001`
   - **Password**: `yourpassword`
   - **Domain**: `your-server-ip`
   - **Transport**: UDP

3. **Register the SIP Client** and make test calls.

---

### **Step 7: Integrate with SuiteCRM (Optional)**
1. **Install AsterLink**:
   ```bash
   mkdir /opt/asterlink
   cd /opt/asterlink
   wget https://github.com/serfreeman1337/asterlink/releases/latest/download/asterlink_x86_64.tar.gz
   tar xvf asterlink_x86_64.tar.gz && rm asterlink_x86_64.tar.gz
   chmod +x asterlink
   ```

2. **Configure AsterLink**:
   - Create `conf.yml`:
     ```bash
     wget https://raw.githubusercontent.com/serfreeman1337/asterlink/master/conf.example.yml
     mv conf.example.yml conf.yml
     nano conf.yml
     ```
   - Edit `conf.yml`:
     ```yaml
     asterisk:
       host: 127.0.0.1
       port: 5038
       user: asterlink
       secret: yourpassword
       dialplan:
         incoming_context: from-pstn
         outgoing_context: macro-dialout-trunk
         ext_context: macro-dial-one
         dial_context: from-internal
     suitecrm:
       url: https://your-suitecrm-domain.com
       api_key: your_api_key
     ```

3. **Start AsterLink**:
   ```bash
   ./asterlink
   ```

4. **Configure SuiteCRM**:
   - Install the AsterLink module in SuiteCRM.
   - Configure the module with the AMI credentials and dialplan contexts.

---

### **Step 8: Troubleshooting**
1. **Check Asterisk Logs**:
   ```bash
   sudo tail -f /var/log/asterisk/messages
   ```

2. **Check AsterLink Logs**:
   ```bash
   cat /opt/asterlink/app.log
   cat /opt/asterlink/err_app.log
   ```

3. **Verify Connectivity**:
   - Use `ping` and `nmap` to verify network connectivity.

---
