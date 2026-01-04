function initHamburgerMenu() {
  const hamburgerButton = document.querySelector('.hamburger-button');
  const hamburgerMenu = document.querySelector('.hamburger-menu');

  if (hamburgerButton && hamburgerMenu) {
    // 既存のイベントリスナーを削除(重複防止)
    const newButton = hamburgerButton.cloneNode(true);
    hamburgerButton.parentNode.replaceChild(newButton, hamburgerButton);
    
    // 新しいボタンに対してイベントリスナーを設定
    const updatedButton = document.querySelector('.hamburger-button');
    updatedButton.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      const menu = document.querySelector('.hamburger-menu');
      menu.classList.toggle('hidden');
    });
  }
}

// 通常のページ読み込み時
document.addEventListener('turbo:load', initHamburgerMenu);

// Turbo Frameの読み込み時(422エラー時など)
document.addEventListener('turbo:frame-load', initHamburgerMenu);

// Turbo Streamの処理後
document.addEventListener('turbo:render', initHamburgerMenu);