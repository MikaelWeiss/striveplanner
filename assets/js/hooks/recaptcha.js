const ReCaptcha = {
  mounted() {
    // Get the site key from the meta tag we'll add
    const siteKey = document.querySelector("meta[name='recaptcha-site-key']").content;
    
    this.el.addEventListener("click", (event) => {
      event.preventDefault();
      grecaptcha.ready(() => {
        grecaptcha.execute(siteKey, {action: 'submit'}).then((token) => {
          document.getElementById("recaptcha-token").value = token;
          document.getElementById("contact-form").submit();
        });
      });
    });
  }
};

export default ReCaptcha; 