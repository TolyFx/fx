sealed class AppStatus {
  const AppStatus();
}

class AppStarting extends AppStatus {
  const AppStarting();
}

class AppLoadDone<S> extends AppStatus {
  final int cost;
  final S data;
  const AppLoadDone(this.cost, this.data);
}

class AppStartSuccess<S> extends AppStatus {
  final S data;
  const AppStartSuccess(this.data);
}

class AppStartFailed extends AppStatus {
  final Object error;
  final StackTrace trace;

  const AppStartFailed(this.error, this.trace);
}
