const dataModel = {
  "masterpassword": "mastertest",
  "2020-05-06-abcdef": "secret-password",
  "Ln0st": "clear text for later"
};


(async function () {
  // Cases
  // - has ?pass or has ?masterpass => set it in LS
  // then
  // - has normal password in LS => decrypt text
  // - has only masterpassword in LS => decrypt password => set LS password => decrypt text

  const urlParams = new URLSearchParams(window.location.search);

  if (urlParams.get("masterpassword")) {
    localStorage.setItem("masterpassword", urlParams.get("masterpassword"))
  }
  let encryptedContents = document.querySelectorAll(".encrypted")
  if (encryptedContents.length == 0) {
    return;
  }

  let encryptionKeys = {}
  encryptedContents.forEach(element => encryptionKeys[element.attributes["encryption-key"].value] = "")

  if (Object.keys(encryptionKeys).length == 1 && urlParams.get("pass")) {
    localStorage.setItem(Object.keys(encryptionKeys)[0].slice(0, -3).split("/").pop(), urlParams.get("pass"))
  }

  for (let element of encryptedContents) {
    const encryptionKey = element.attributes["encryption-key"].value.slice(0, -3).split("/").pop()
    if (!localStorage.getItem(encryptionKey) && localStorage.getItem("masterpassword")) {
      const key = await decrypt(passwords[encryptionKey], localStorage.getItem("masterpassword"))
      localStorage.setItem(encryptionKey, key.trim())
    }
    if (localStorage.getItem(encryptionKey)) {
      await decrypt(element.textContent.trim(), localStorage.getItem(encryptionKey))
        .then(result => element.innerHTML = sanitize(result.trim()))
        .then(() => {
          if (!urlParams.get("pass") && Object.keys(encryptionKeys).length == 1) {
            history.pushState({}, "", "?pass=" + localStorage.getItem(encryptionKey))
          }
        })
    } else {
      element.innerHTML = "[ENCRYPTED - MISSING KEY]"
    }
  }

  async function decrypt(str, key) {
    if (localStorage.getItem(str)) {
      return localStorage.getItem(str)
    }
    console.log(str)
    const encryptedMessage = await openpgp.readMessage({
      armoredMessage: atob(str)
    });
    const { data: decrypted } = await openpgp.decrypt({
      message: encryptedMessage,
      passwords: [key],
    });
    localStorage.setItem(str, decrypted)
    return decrypted
  }

})()



function sanitize(str) {
  if (str.startsWith('\"') && str.endsWith('\"')) {
    return str.slice(1, -1)
  }
  return str
}
