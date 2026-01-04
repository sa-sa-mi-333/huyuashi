// 要素を変更したときにページ全体がリロードされないようにturbo:loadを設定する //
document.addEventListener('turbo:load', () => {
  const hamburgerButton = document.querySelector('.hamburger-button');
  const hamburgerMenu = document.querySelector('.hamburger-menu');

  if (hamburgerButton && hamburgerMenu) {
    hamburgerButton.addEventListener('click', () => {
      hamburgerMenu.classList.toggle('hidden');
    });
  }
});