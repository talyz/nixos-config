(require 'exwm)
(require 'exwm-randr)

(defun exwm-run (command)
  (interactive (list (read-shell-command "$ ")))
  (let ((cmd (concat
              "systemd-run --user "
              command)))
    (start-process-shell-command cmd nil cmd)))
(define-key exwm-mode-map (kbd "s-SPC") 'exwm-run)
(global-set-key (kbd "s-SPC") 'exwm-run)

(dotimes (i 9)
  (exwm-input-set-key (kbd (format "s-%d" (+ i 1)))
                      `(lambda ()
                         (interactive)
                         (exwm-workspace-switch-create ,i))))

(add-hook 'exwm-update-class-hook
          (lambda ()
            (exwm-workspace-rename-buffer exwm-class-name)))

;; Note: This approach does not work with Emacs 25 due to a bug of Emacs.
(add-hook 'exwm-manage-finish-hook
          (lambda ()
            (when (and exwm-class-name
                       (or (string= exwm-class-name "URxvt")
                           (string= exwm-class-name "Gnome-terminal")))
              (exwm-input-set-local-simulation-keys '(([?\C-c ?\C-c] . ?\C-c))))))

(add-hook 'exwm-update-title-hook
          (lambda ()
            (let ((tilde-exwm-title
                   (replace-regexp-in-string (getenv "HOME") "~" exwm-title)))
              (exwm-workspace-rename-buffer (format "%s: %s" exwm-class-name tilde-exwm-title)))))

;; Display time in modeline
(setq display-time-24hr-format t)
(display-time-mode 1)

;; Battery is useful too
(display-battery-mode)

(require 'desktop-environment)
(desktop-environment-mode)
(setq desktop-environment-brightness-set-command "light %s")
(setq desktop-environment-brightness-normal-decrement "-U 10")
(setq desktop-environment-brightness-small-decrement "-U 5")
(setq desktop-environment-brightness-normal-increment "-A 10")
(setq desktop-environment-brightness-small-increment "-A 5")
(setq desktop-environment-brightness-get-command "light")
(setq desktop-environment-brightness-get-regexp "\\([0-9]+\\)\\.[0-9]+")
(setq desktop-environment-screenlock-command "loginctl lock-session")
(setq desktop-environment-screenshot-command "flameshot gui")

(require 'exwm-systemtray)
(exwm-systemtray-enable)
(setq exwm-systemtray-height 16)

(setq exwm-input-simulation-keys
 (mapcar (lambda (c) (cons (kbd (car c)) (cdr c)))
         `(("C-b" . left)
           ("C-f" . right)
           ("C-p" . up)
           ("C-n" . down)
           ("C-a" . home)
           ("C-e" . end)
           ("M-v" . prior)
           ("C-v" . next)
           ("C-d" . delete)
           ("C-m" . return)
           ("C-i" . tab)
           ("C-g" . escape)
           ("C-s" . ?\C-f)
           ("C-y" . ?\C-v)
           ("M-w" . ?\C-c)
           ("M-<" . C-home)
           ("M->" . C-end)
           ("C-M-h" . C-backspace))))

(exwm-input-set-key
 (kbd "M-o")
 'ace-window)

(exwm-input-set-key
 (kbd "s-g")
 (defun pnh-ff-gsearch ()
   (interactive)
   (browse-url
    (format "https://google.com/search?q=%s"
            (read-string "Terms: ")))))

(exwm-input-set-key
 (kbd "s-s")
 (defun pnh-ff-url ()
   (interactive)
   (browse-url
    (read-string "URL: "))))

(exwm-input-set-key
 (kbd "s-c")
 (defun pnh-terminal ()
   (interactive)
   (let ((cmd "systemd-run --user gnome-terminal"))
     (start-process-shell-command cmd nil cmd))))

(setq browse-url-firefox-arguments '("-new-window"))
(setq exwm-randr-workspace-output-plist '(1 "DP-2-2"))
(exwm-init)
(exwm-randr-enable)
