# Setup authentication for steamctl without user interaction. After running
# this, steamctl will remember the last user + password and other scripts can
# use it without authentication.
#
# Requires some environment variables: STEAMCTL_USER, STEAMCTL_PASSWD,
# STEAMCTL_SECRET, and optionally STEAMCTL_PATH.
#
# STEAMCTL_SECRET is obtained by setting up a steamctl authenticator manually,
# and viewing the authenticator file at $USER_DATA_DIR/authenticator/$USER.json
#
# Warning: do not use on shared machines, as STEAMCTL_SECRET is exposed to `ps`.
#
# Does not work on windows, because pexpect does not work on windows.
import pexpect
import sys
import os
import time

def printcmd(str):
    print("\n+", str, flush=True)
    return str

def authenticator_remove(steamctl, user):
    # Remove existing authenticator, if any
    cmd = printcmd(f"{steamctl} authenticator remove --force {user}")
    output, exitstatus = pexpect.run(cmd, timeout=5, withexitstatus=True)
    print(output.decode('utf-8'), flush=True)

def authenticator_add(steamctl, user, passwd, secret):
    # I don't like putting the secret in the command line like this - `ps` could see it.
    # But I'm running this on private CI machines, so it *should* be okay, I think.
    # Also, at least the password is still obscured.
    cmd = printcmd(f"{steamctl} authenticator add --from-secret {secret} {user}")
    child = pexpect.spawn(cmd, timeout=5)
    child.logfile_read = sys.stdout.buffer
    index = child.expect(["Enter password for .*:", pexpect.EOF])
    print("\nauth_add expected", index)
    if index == 0:
        child.sendline(passwd)
    child.expect("Authenticator added successfully")
    child.read()
    child.close()
    if (child.exitstatus):
        raise Exception("steamctl exitstatus: "+str(child.exitstatus))

def authenticator_code(steamctl, user):
    cmd = printcmd(f"{steamctl} authenticator code {user}")
    output, exitstatus = pexpect.run(cmd, timeout=5, withexitstatus=True)
    if (exitstatus):
        raise Exception("steamctl exitstatus: "+str(exitstatus))
    return output.decode('utf-8').strip()

def login_with_2fa(steamctl, user, passwd):
    cmd = printcmd(f"{steamctl} --user {user} depot info -a 238960")
    child = pexpect.spawn(cmd, timeout=30)
    child.logfile_read = sys.stdout.buffer
    index = child.expect(["Password:", pexpect.EOF])
    if index == 0:
        child.sendline(passwd)
        index = child.expect(["Enter 2FA code:", pexpect.EOF])
        # I don't understand why waitnoecho() is necessary - but without it,
        # 2fa codes that match my phone's are consistently rejected
        child.waitnoecho()
        if index == 0:
            code = authenticator_code(steamctl=steamctl, user=user)
            print("authenticator code 1:", str(code), flush=True)
            child.sendline(code)
            # retry once
            index = child.expect(["Incorrect code. Enter 2FA code:", pexpect.EOF])
            child.waitnoecho()
            if index == 0:
                time.sleep(5)
                code = authenticator_code(steamctl=steamctl, user=user)
                print("authenticator code 2:", str(code), flush=True)
                time.sleep(3)
                # retry
                child.sendline(code)
                child.expect(pexpect.EOF)
    child.read()
    child.close()
    if (child.exitstatus):
        raise Exception("steamctl exitstatus: "+str(child.exitstatus))

def verify_auth_remembered(steamctl):
    cmd = printcmd(f"{steamctl} depot info -a 238960")
    output, exitstatus = pexpect.run(cmd, timeout=5, withexitstatus=True)
    print(output.decode('utf-8'), flush=True)
    if (exitstatus):
        raise Exception("steamctl exitstatus: "+str(exitstatus))

def main():
    # Steam account login
    user = os.environ['STEAMCTL_USER']
    passwd = os.environ['STEAMCTL_PASSWD']
    # Mobile authenticator secret. We set up this machine as if it were a permanent
    # auntenticator, and generate a code to log in.
    secret = os.environ['STEAMCTL_SECRET']
    # steamctl binary path
    #steamctl = "./.local/bin/steamctl"
    steamctl = os.environ.get('STEAMCTL_PATH', "steamctl")

    authenticator_remove(steamctl=steamctl, user=user)
    authenticator_add(steamctl=steamctl, user=user, passwd=passwd, secret=secret)
    #authenticator_code(steamctl=steamctl, user=user)
    login_with_2fa(steamctl=steamctl, user=user, passwd=passwd)
    verify_auth_remembered(steamctl=steamctl)

if __name__=="__main__":
    main()
