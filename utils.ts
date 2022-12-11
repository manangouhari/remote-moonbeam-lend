function sleep(ms: number | undefined) {
  return new Promise((resolve: any) => {
    setTimeout(() => {
      resolve();
    }, ms);
  });
}

export { sleep };
