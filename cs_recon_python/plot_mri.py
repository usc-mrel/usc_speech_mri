import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation


def coil_img_play(image, frame_intvl, name='Coil Images', column=4):
    """Play dynamic coil images.

    Ixputs:
    image -- size: [nt, ncoils, nx, ny]

    Output:
    ani -- animation
    """

    ncoils = np.size(image, axis=1)
    nt = np.size(image, axis=0)
    row = int(np.floor(ncoils/column))
    tail = ncoils % column
    fig1 = plt.figure(1)
    fig1.suptitle(name, fontsize=16)
    axs = fig1.subplots(row+int(np.ceil(tail/column)), column)
    ims = []
    for frame in range(nt):
        temp = []
        for r in range(row):
            for c in range(column):
                temp.append(axs[r][c].imshow(np.rot90(abs(image[frame, r*column+c, :, :])), cmap='gray'))
        for c in range(tail):
            temp.append(axs[row][c].imshow(np.rot90(abs(image[frame, row*column+c, :, :])), cmap='gray'))
        ims.append(temp)
    ani = animation.ArtistAnimation(fig1, ims, interval=frame_intvl, repeat_delay=3000, blit=True)
    return ani


def sos_play(image, frame_intvl, name='SoS Image'):
    """Play dynamic sum-of-square coil-combined images.

    Ixputs:
    image -- size: [nt, ncoils, nx, ny]

    Output:
    ani -- animation
    """

    nt = np.size(image, axis=0)
    fig2 = plt.figure(2)
    fig2.suptitle(name, fontsize=16)
    ims = []
    for frame in range(nt):
        sos = np.sqrt(np.sum(np.conj(image[frame, :, :, :])*image[frame, :, :, :], 0))
        ims.append([plt.imshow(np.rot90(np.real(sos)), cmap='gray')])
    ani = animation.ArtistAnimation(fig2, ims, interval=frame_intvl)
    return ani


def img_play(image, fps=83.3, name='recon_img'):
    """Play dynamic images.

    Ixputs:
    image -- size: [nt, nx, ny]

    Output:
    ani -- animation
    """

    Writer = animation.writers['ffmpeg']
    writer = Writer(metadata=dict(artist='USC-MREL'), fps=fps, bitrate=1800)

    nt = np.size(image, axis=0)

    fig, ax = plt.subplots(1, figsize=(1, 1))
    fig.subplots_adjust(0, 0, 1, 1)
    ax.axis('off')

    # fig.suptitle(name, fontsize=16)
    ims = []
    for frame in range(nt):
        ims.append([ax.imshow(np.rot90(np.abs(image[frame, :, :])), cmap='gray', animated=True)])
    ani = animation.ArtistAnimation(fig, ims, repeat_delay=3000, blit=True)

    ani.save('{}.mp4'.format(name), writer=writer)
    # plt.show()
    return ani
